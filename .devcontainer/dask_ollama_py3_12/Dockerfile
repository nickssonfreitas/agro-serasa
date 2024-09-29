FROM daskdev/dask-notebook:2024.8.1-py3.12

# Substituindo o ENTRYPOINT
#ENTRYPOINT []

# Configuração de variáveis de ambiente
ENV NB_USER=jovyan
ENV NB_UID=1000
ENV NB_GID=100
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONIOENCODING=utf-8
ENV LC_ALL=C.UTF-8
ENV JUPYTER_PORT=8888
ENV GRANT_SUDO=yes
ENV HOME_DIR=/home/$NB_USER
ENV NB_PREFIX=/
ENV SHELL=/bin/bash

# ARG variables
#ARG S6_VERSION=v2.2.0.3
#ARG S6_ARCH="amd64"
ARG KUBECTL_ARCH="amd64"
ARG KUBECTL_VERSION=v1.21.0

##############################################################################
# Atualização e instalação de pacotes essenciais
##############################################################################
USER root
RUN apt-get update --yes \
    && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        libncurses5 \
        libncursesw5 \
        patch \
        wget \
        rsync \
        unzip \
        zip \
        jq \
        gnupg \
        libtcmalloc-minimal4 \
        locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen
##############################################################################
# Instalação de nano e vim
##############################################################################
RUN apt-get update \
&& apt-get install -y nano vim \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

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
# USER root
# RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER} \
# && mkdir -p ${HOME} \
# && chown -R ${NB_USER}:users ${HOME} \
# && chown -R ${NB_USER}:users /usr/local/bin

 #--------------------------------------------------------

##############################################################################
# Instalação do Ollama
##############################################################################
USER root
COPY ollama /usr/bin/
RUN chmod +x /usr/bin/ollama
RUN useradd -r -s /bin/false -m -d /usr/share/ollama ollama
COPY ollama.service /etc/systemd/system/

##############################################################################
# Instalação do Tiny
##############################################################################
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini & chown -R ${NB_USER}:users /usr/local/bin/tini


##############################################################################
# Instalação de dependências Python
##############################################################################
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# # create user and set required ownership
# RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER} \
#  && mkdir -p ${HOME} \
#  && chown -R ${NB_USER}:users ${HOME} \
#  && chown -R ${NB_USER}:users /usr/local/bin \
#  && chown -R ${NB_USER}:users /usr/local/bin/tini

##############################################################################
# Configuração do Jupyter Notebook
##############################################################################
# # Script to prepare environment and start Jupyter Lab
COPY --chown=${NB_USER}:users startup.sh /opt
RUN chmod +x /opt/startup.sh

WORKDIR /home/$NB_UID
USER $NB_UID
EXPOSE 8888
ENTRYPOINT ["tini", "--"]
CMD ["/opt/startup.sh"]