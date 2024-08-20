# Base mpi-operator dockerfile from https://github.com/kubeflow/mpi-operator/blob/master/build/base/Dockerfile
# Added open-mpi https://github.com/kubeflow/mpi-operator/blob/master/build/base/openmpi.Dockerfile
# Added configuration for OpenM++ from https://github.com/openmpp/docker/blob/master/ompp-run-debian/Dockerfile
# Added kubectl cli for interacting with kubeapi server from containers

FROM debian:bookworm

ARG port=2222

RUN apt update \
        && apt-get upgrade -y \
        && apt install -y --no-install-recommends \
			openssh-server \
			openssh-client \
            libcap2-bin \
            openmpi-bin \
            sqlite3 \
            curl \
            ca-certificates \
            minizip \
		&& rm -rf /var/lib/apt/lists/*

# Add priviledge separation directoy to run sshd as root.
RUN mkdir -p /var/run/sshd

# Add capability to run sshd as non-root.
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/sshd
RUN apt remove libcap2-bin -y

# Allow OpenSSH to talk to containers without asking for confirmation
# by disabling StrictHostKeyChecking.
# mpi-operator mounts the .ssh folder from a Secret. For that to work, we need
# to disable UserKnownHostsFile to avoid write permissions.
# Disabling StrictModes avoids directory and files read permission checks.
RUN sed -i "s/[ #]\(.*StrictHostKeyChecking \).*/ \1no/g" /etc/ssh/ssh_config \
    && echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config \
    && sed -i "s/[ #]\(.*Port \).*/ \1$port/g" /etc/ssh/ssh_config \
    && sed -i "s/#\(StrictModes \).*/\1no/g" /etc/ssh/sshd_config \
    && sed -i "s/#\(Port \).*/\1$port/g" /etc/ssh/sshd_config

# Install kubectl cli to be able to utilize file transfer functionality between containers
ARG KUBECTL_VERSION=v1.28.2
ARG KUBECTL_URL=https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ARG KUBECTL_SHA=c922440b043e5de1afa3c1382f8c663a25f055978cbc6e8423493ec157579ec5

RUN curl -LO "${KUBECTL_URL}" \
    && echo "${KUBECTL_SHA} kubectl" | sha256sum -c - \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Set local openM++ timezone, default ulimit
RUN rm -f /etc/localtime && \
ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime && \
echo "ulimit -S -s 65536" >> etc/bash.bashrc

# Add non-root user
RUN useradd -m mpiuser
WORKDIR /home/mpiuser

# Configurations for running sshd as non-root.
COPY --chown=mpiuser sshd_config .sshd_config
RUN echo "Port $port" >> /home/mpiuser/.sshd_config

# Stepdown to non-root user
USER mpiuser

SHELL ["/bin/bash"]

# default command check MPIEXEC verson, when used as a kubernetes container override with custom mpiexec execution
CMD mpiexec -V && ulimit -S -s