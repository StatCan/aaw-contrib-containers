FROM ubuntu:20.04

USER root

ARG NOTROOTUSER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
WORKDIR /home/$NOTROOTUSER

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      'jq' \
      'curl' \
      'ca-certificates' \
      'git' \
      'postgresql-client-common'

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



RUN chmod -R 755 /home/$NOTROOTUSER
RUN chown -R $NOTROOTUSER /home/$NOTROOTUSER
USER $NOTROOTUSER

#infinite sleep
ENTRYPOINT ["tail", "-f", "/dev/null"]
