#!/bin/bash

set -e  # Interrompe o script em caso de erro

# Função para logar mensagens com timestamp
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Função para desinstalar Docker
uninstall_docker() {
    log "Parando os serviços do Docker"
    sudo systemctl stop docker
    sudo systemctl stop docker.socket

    log "Removendo pacotes Docker"
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

    log "Removendo diretórios relacionados ao Docker"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /etc/docker
    sudo rm -rf /var/run/docker.sock
    sudo rm -rf /usr/bin/docker-compose
    sudo rm -rf ~/.docker

    log "Removendo o grupo Docker"
    sudo groupdel docker

    log "Docker desinstalado com sucesso"
}

# Função para instalar Docker
install_docker() {
    log "Atualizando o sistema"
    sudo yum update -y

    log "Instalando dependências necessárias"
    sudo yum install -y yum-utils

    log "Adicionando o repositório Docker"
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    log "Instalando o Docker"
    sudo yum install -y docker-ce docker-ce-cli containerd.io

    log "Iniciando e habilitando o Docker"
    sudo systemctl start docker
    sudo systemctl enable docker

    log "Verificando a instalação do Docker"
    sudo docker --version
    sudo docker run hello-world

    log "Docker instalado e configurado com sucesso"
}

# Executa as funções
log "Iniciando a desinstalação e reinstalação do Docker"
uninstall_docker
install_docker
