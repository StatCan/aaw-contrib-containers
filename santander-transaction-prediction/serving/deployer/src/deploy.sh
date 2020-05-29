#!/bin/bash -e

# Copyright 2020 Statistics Canada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

KUBERNETES_NAMESPACE="${KUBERNETES_NAMESPACE:-kubeflow}"
SERVER_NAME="${SERVER_NAME:-model-server}"

while (($#)); do
   case $1 in
     "--model-export-path")
       shift
       MODEL_EXPORT_PATH="$1"
       shift
       ;;
     "--cluster-name")
       shift
       CLUSTER_NAME="$1"
       shift
       ;;
     "--namespace")
       shift
       KUBERNETES_NAMESPACE="$1"
       shift
       ;;
     "--server-name")
       shift
       SERVER_NAME="$1"
       shift
       ;;
     "--pvc-name")
       shift
       PVC_NAME="$1"
       shift
       ;;
     "--service-type")
       shift
       SERVICE_TYPE="$1"
       shift
       ;;
     *)
       echo "Unknown argument: '$1'"
       exit 1
       ;;
   esac
done

if [ -z "${MODEL_EXPORT_PATH}" ]; then
  echo "You must specify a path to the saved model"
  exit 1
fi

echo "Deploying the model '${MODEL_EXPORT_PATH}'"

# Ensure the server name is not more than 63 characters.
SERVER_NAME="${SERVER_NAME:0:63}"
# Trim any trailing hyphens from the server name.
while [[ "${SERVER_NAME:(-1)}" == "-" ]]; do SERVER_NAME="${SERVER_NAME::-1}"; done

echo "Deploying ${SERVER_NAME} to the cluster ${CLUSTER_NAME}"

# Connect kubectl to the local cluster
kubectl config set-cluster "${CLUSTER_NAME}" --server=https://kubernetes.default --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials pipeline --token "$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
kubectl config set-context kubeflow --cluster "${CLUSTER_NAME}" --user pipeline
kubectl config use-context kubeflow

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kfdemo
  name: kfdemo-service
  namespace: kubeflow
spec:
  ports:
  - name: grpc-tf-serving
    port: 9000
    targetPort: 9000
  - name: http-tf-serving
    port: 8500
    targetPort: 8500
  selector:
    app: kfdemo
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kfdemo
  name: kfdemo
  namespace: kubeflow
spec:
  selector:
    matchLabels:
      app: kfdemo
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"
      labels:
        app: kfdemo
        version: v1
    spec:
      containers:
      - args:
        - --port=9000
        - --rest_api_port=8500
        - --model_name=${SERVER_NAME}
        - --model_base_path=${MODEL_EXPORT_PATH}
        # - --monitoring_config_file=/var/config/monitoring_config.txt
        command:
        - /usr/bin/tensorflow_model_server
        env:
        - name: AWS_ACCESS_KEY_ID
          value: minio
        - name: AWS_SECRET_ACCESS_KEY
          value: minio123
        - name: AWS_REGION
          value: us-west-1
        - name: S3_USE_HTTPS
          value: "0"
        - name: S3_VERIFY_SSL
          value: "0"
        - name: S3_ENDPOINT
          value: 'minio-service.kubeflow.svc.cluster.local:9000'
        image: tensorflow/serving:1.11.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          initialDelaySeconds: 30
          periodSeconds: 30
          tcpSocket:
            port: 9000
        name: s3
        ports:
        - containerPort: 9000
        - containerPort: 8500
        resources:
          limits:
            cpu: "4"
            memory: 4Gi
          requests:
            cpu: "1"
            memory: 1Gi
      #   volumeMounts:
      #   - mountPath: /var/config/
      #     name: config-volume
      # volumes:
      # - configMap:
      #     name: s3-config
      #   name: config-volume
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  labels:
  name: kfdemo-service
  namespace: kubeflow
spec:
  host: kfdemo-service
  subsets:
  - labels:
      version: v1
    name: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  labels:
  name: kfdemo-service
  namespace: kubeflow
spec:
  gateways:
  - kubeflow-gateway
  hosts:
  - '*'
  http:
  - match:
    - method:
        exact: POST
      uri:
        prefix: /tfserving/models/demo
    rewrite:
      uri: /v1/models/demo:predict
    route:
    - destination:
        host: kfdemo-service
        port:
          number: 8500
        subset: v1
      weight: 100
EOF
