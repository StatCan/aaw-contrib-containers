FROM ubuntu:20.04

USER root

ARG NOTROOTUSER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
WORKDIR /home/$NOTROOTUSER
ENV GOPATH=/home/jovyan/go

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'jq' \
      'curl' \
      'ca-certificates' \
      'git'

# Install kubectl
ARG KUBECTL_VERSION=v1.23.0
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=2d0f5ba6faa787878b642c151ccb2c3390ce4c1e6c8e2b59568b3869ba407c4f

RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Operate in non root
RUN useradd $NOTROOTUSER
ENV NOTROOTUSER="${NOTROOTUSER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID}

#Install GO
ARG GO_VERSION=1.16.7
ARG GO_SHA=7fe7a73f55ba3e2285da36f8b085e5c0159e9564ef5f63ee0ed6b818ade8ef04
ARG CRANE_VERSION=v0.8.0

RUN curl -OL https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz \
    && echo "${GO_SHA} go$GO_VERSION.linux-amd64.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xvf go$GO_VERSION.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

#Install Crane
RUN go install github.com/google/go-containerregistry/cmd/crane@$CRANE_VERSION

COPY 1-RuntimeScanning /home/$NOTROOTUSER
COPY run-job.sh /home/$NOTROOTUSER
RUN chmod -R 755 /home/$NOTROOTUSER
RUN chown -R $NOTROOTUSER /home/$NOTROOTUSER
USER $NOTROOTUSER

# docker run -it --rm --entrypoint /bin/bash test
CMD ["./run-job.sh"]
