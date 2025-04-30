#!/bin/bash

# 1- Configurar o ambiente instalando os seguintes pacotes
sudo yum install gcc make -y
sudo yum update -y
sudo yum install -y gcc kernel-devel-$(uname -r)

# 2- Baixar o driver da Amazon S3 e definir permissões de execução
aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
chmod +x NVIDIA-Linux-x86_64*.run

# 3- Compilar e instalar o driver
# Quando solicitado, aceite o contrato de licença e especifique as opções de instalação conforme necessário (você pode aceitar as opções padrão).
# Confirme que o driver está funcional. A resposta para o comando a seguir lista a versão instalada do driver NVIDIA e detalhes sobre as GPUs.
sudo CC=/usr/bin/gcc10-cc ./NVIDIA-Linux-x86_64*.run --tmpdir /temp --silent

# 4- Verificar se está funcionando e finalizar a instalação
sudo touch /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf

# 5- Instalar o Docker NVIDIA
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/amzn2/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo
sudo yum install nvidia-docker2 -y
sudo systemctl restart docker

# Reiniciar o sistema para aplicar as mudanças
#sudo reboot