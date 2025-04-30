#!/bin/bash

# Verificar se os argumentos foram fornecidos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <File-System-DNS-Name> <Mount-Point>"
    exit 1
fi

# Variáveis - Recebidas como argumentos
EFS_DNS_NAME=$1
MOUNT_POINT=$2

# Atualizar e instalar o cliente NFS
sudo yum update -y
sudo yum install -y nfs-utils

# Criar o ponto de montagem
sudo mkdir -p $MOUNT_POINT

# Montar o EFS
sudo mount -t nfs4 -o nfsvers=4.1 $EFS_DNS_NAME:/ $MOUNT_POINT


# Verificar se o EFS está montado
df -h | grep $MOUNT_POINT

# Adicionar ao fstab para montagem automática na inicialização, se não existir
if ! grep -q "$FSTAB_ENTRY" /etc/fstab; then
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
fi

# Reiniciar o serviço NFS
sudo systemctl restart nfs

# Obter o nome do usuário atual
USUARIO_ATUAL=$(whoami)

# Ajustar a propriedade e permissões do diretório de montagem
sudo chown $USUARIO_ATUAL:$USUARIO_ATUAL $MOUNT_POINT
sudo chmod 755 $MOUNT_POINT
