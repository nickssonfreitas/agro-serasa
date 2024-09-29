#FROM nvidia/cuda:10.0-devel-ubuntu18.04
FROM nvcr.io/nvidia/pytorch:19.06-py3

##############################################################################
### Kubeflow Args
# common environemnt variables
##############################################################################
ENV NB_USER=jovyan
ENV GRANT_SUDO=yes
ENV NB_UID=1000
ENV NB_PREFIX=/
ENV HOME=/home/$NB_USER
ENV SHELL=/bin/bash
ENV SSL_VERSION=1.0.2u

##############################################################################
# args - software versions
##############################################################################
ARG KUBECTL_ARCH="amd64"
ARG KUBECTL_VERSION=v1.21.0
ARG S6_ARCH="amd64"

##############################################################################
# renovate: datasource=github-tags depName=just-containers/s6-overlay versioning=loose
##############################################################################
ARG S6_VERSION=v2.2.0.3

# set shell to bash
SHELL ["/bin/bash", "-c"]

##############################################################################
# Temporary Installation Directory
##############################################################################
ENV STAGE_DIR=/tmp
RUN mkdir -p ${STAGE_DIR}

##############################################################################
# to avoid interaction with apt-get
##############################################################################
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -yq curl

##############################################################################
# Client Liveness & Uncomment Port 22 for SSH Daemon
##############################################################################
# Keep SSH client alive from server side
RUN echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
RUN cp /etc/ssh/sshd_config ${STAGE_DIR}/sshd_config && \
        sed "0,/^#Port 22/s//Port 22/" ${STAGE_DIR}/sshd_config > /etc/ssh/sshd_config

	
##############################################################################	
# Allow OpenSSH to talk to containers without asking for confirmation
##############################################################################
RUN mkdir -p /var/run/sshd
RUN cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config


##############################################################################
## SSH daemon port inside container cannot conflict with host OS port
###############################################################################
ENV SSH_PORT=2222
RUN cat /etc/ssh/sshd_config > ${STAGE_DIR}/sshd_config && \
        sed "0,/^#Port 22/s//Port ${SSH_PORT}/" ${STAGE_DIR}/sshd_config > /etc/ssh/sshd_config

##############################################################################
# install - s6 overlay -- Kubeflow notebooks
##############################################################################
RUN export GNUPGHOME=/tmp/ \
 && curl -sL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}-installer" -o /tmp/s6-overlay-${S6_VERSION}-installer \
 && curl -sL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}-installer.sig" -o /tmp/s6-overlay-${S6_VERSION}-installer.sig \
 && chmod +x /tmp/s6-overlay-${S6_VERSION}-installer \
 && /tmp/s6-overlay-${S6_VERSION}-installer / \
 && rm /tmp/s6-overlay-${S6_VERSION}-installer.sig /tmp/s6-overlay-${S6_VERSION}-installer

############################################################################## 
# install - kubectl -- Kubeflow notebooks
##############################################################################
USER root
RUN curl -sL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl
RUN curl -sL "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
 && echo "$(cat /tmp/kubectl.sha256) /usr/local/bin/kubectl" | sha256sum --check \
 && rm /tmp/kubectl.sha256 \
 && chmod +x /usr/local/bin/kubectl

############################################################################## 
# create user and set required ownership -- Kubeflow
##############################################################################
RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER} \
 && mkdir -p ${HOME} \
 && chown -R ${NB_USER}:users ${HOME} \
 && chown -R ${NB_USER}:users /usr/local/bin \
 && chown -R ${NB_USER}:users /etc/s6
 #--------------------------------------------------------

##############################################################################
# set locale configs -- Kubeflow
##############################################################################
ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

##############################################################################
#-----------------------------------
##############################################################################
# kubeflow
USER $NB_UID

# Set a working directory inside the container.
WORKDIR /app

# Copy the fairseq_0_12_0.tar.gz file from your local machine to the container.
COPY packages/fairseq-0.12.0.tar.gz /app/

# Install any necessary dependencies if required.
# For example, if your build.sh script requires specific tools or libraries.

# Extract the tar.gz file.
RUN tar -xvf fairseq-0.12.0.tar.gz

WORKDIR /app/fairseq

# Make the build.sh script executable.
RUN chmod +x build.sh

# Run the build.sh script.
RUN bash build.sh

##############################################################################
# Some Packages
##############################################################################

##############################################################################
# Instalação de dependências Python
##############################################################################
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR ${HOME}

ENV NB_PREFIX=/

EXPOSE 8888

CMD ["sh", "-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]