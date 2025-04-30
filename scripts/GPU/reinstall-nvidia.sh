#!/bin/bash

set -e  # Interrompe o script em caso de erro

# Função para logar mensagens com timestamp
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Função para desinstalar drivers NVIDIA existentes
uninstall_nvidia_drivers() {
    log "Removendo drivers NVIDIA existentes (se houver)"
    if lsmod | grep -q nvidia; then
        sudo rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
        sudo rmmod nvidia || true
    fi
    sudo yum remove -y nvidia-driver nvidia-docker2 || true
    sudo rm -rf /usr/local/cuda* /usr/lib64/nvidia* /usr/bin/nvidia* /etc/modprobe.d/nvidia* /var/lib/nvidia* || true
    log "Drivers NVIDIA removidos com sucesso (se existiam)"
}

# Função para instalar drivers NVIDIA e dependências
install_nvidia_drivers() {
    log "Instalando pacotes necessários"
    sudo yum update -y
    sudo yum install -y gcc make kernel-devel-$(uname -r)

    log "Instalando gcc10-cc"
    sudo yum install -y gcc10

    log "Baixando o driver NVIDIA da Amazon S3"
    aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
    chmod +x NVIDIA-Linux-x86_64*.run

    log "Instalando o driver NVIDIA"
    sudo CC=/usr/bin/gcc10 ./NVIDIA-Linux-x86_64*.run --silent --no-cc-version-check --tmpdir /var/tmp

    log "Configurando o driver NVIDIA"
    sudo touch /etc/modprobe.d/nvidia.conf
    echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf

    log "Instalação e configuração do driver NVIDIA concluídas com sucesso"
}

# Executa as funções
log "Iniciando a desinstalação e instalação do driver NVIDIA"
#uninstall_nvidia_drivers
install_nvidia_drivers
