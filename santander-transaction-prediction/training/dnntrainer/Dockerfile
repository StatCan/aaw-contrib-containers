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

ARG TF_TAG
FROM tensorflow/tensorflow:$TF_TAG

# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'ca-certificates' \
      'python-dev' \
      'python-setuptools' \
      'git' \
      'wget' \
      'unzip' \
    && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get install --no-install-recommends -y -q build-essential && \
    pip install pyyaml==3.12 six==1.11.0 \
        tensorflow-transform==0.6.0 pandas gcsfs \
        tensorflow-model-analysis==0.6.0 && \
    apt-get --purge autoremove -y build-essential

ADD src /ml/src

WORKDIR /ml

RUN cd src/ && \
    python setup.py install

WORKDIR /ml/src/

ENTRYPOINT ["python", "-m", "trainer.boosted"]

# COPY kubeflow-pipelines-demo .
