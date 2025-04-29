#!/bin/bash

# Verificar atualizações de versão do DNF
dnf check-release-update

# Atualizar o sistema para a última versão
sudo dnf upgrade --releasever=latest -y
sudo dnf update -y

# Instalar DKMS para suporte a módulos do kernel
sudo dnf install -y dkms
sudo systemctl enable dkms

# Verificar a versão do kernel e instalar pacotes necessários
if (uname -r | grep -q ^6.12.); then
  sudo dnf install -y kernel-devel-$(uname -r) kernel6.12-modules-extra
else
  sudo dnf install -y kernel-devel-$(uname -r) kernel-modules-extra
fi

# Adicionar repositório e instalar driver NVIDIA e toolkit CUDA
cd /tmp
if (arch | grep -q x86); then
  sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/amzn2023/x86_64/cuda-amzn2023.repo
  sudo dnf install -y nvidia-driver::560-dkms
  sudo dnf install -y cuda-toolkit
else
  sudo dnf install -y vulkan-devel libglvnd-devel elfutils-libelf-devel xorg-x11-server-Xorg
  cd /var/tmp
  wget https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_570.124.06_linux_sbsa.run
  chmod +x ./cuda*.run
  sudo ./cuda_*.run --driver --toolkit --tmpdir=/var/tmp --silent
fi

# Adicionar repositório e instalar nvidia-container-toolkit
if (! dnf search nvidia | grep -q nvidia-container-toolkit); then
  sudo dnf config-manager --add-repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
fi
sudo dnf install -y nvidia-container-toolkit

# Instalar e configurar Docker
sudo dnf install -y docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Configurar runtime do Docker para usar NVIDIA
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Desabilitando o GSP
sudo touch /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf

# # Adicionar o módulo NVIDIA ao arquivo /etc/modules para carregamento automático na inicialização
# echo "nvidia" | sudo tee -a /etc/modules

# # Criar ou editar o arquivo /etc/modprobe.d/blacklist-nouveau.conf para desativar o driver Nouveau
# sudo bash -c 'echo -e "blacklist nouveau\noptions nouveau modeset=0" > /etc/modprobe.d/blacklist-nouveau.conf'

# # Recriar a imagem initramfs para aplicar as mudanças
# sudo dracut --force

# Verificar se o driver NVIDIA foi instalado corretamente
if ! nvidia-smi; then
  echo "Erro: O comando nvidia-smi falhou. Verifique a instalação do driver NVIDIA."
  exit 1
fi

# Verificar se o toolkit CUDA está instalado corretamente
if ! /usr/local/cuda/bin/nvcc -V; then
  echo "Erro: O toolkit CUDA não está instalado corretamente."
  exit 1
fi

# Verificar se o nvidia-container-cli está funcionando
if ! nvidia-container-cli -V; then
  echo "Erro: O nvidia-container-cli não está funcionando corretamente."
  exit 1
fi

# Reiniciar o sistema para aplicar todas as mudanças
sudo reboot

# Comandos de verificação após reinicialização (comentados para referência)
# nvidia-smi
# /usr/local/cuda/bin/nvcc -V
# nvidia-container-cli -V
# sudo docker run --rm --runtime=nvidia --gpus all nvidia/cuda:12.6.2-cudnn-devel-ubuntu22.04 nvidia-smi
