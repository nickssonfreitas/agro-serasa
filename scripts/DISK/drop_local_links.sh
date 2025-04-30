#!/bin/bash

# Inclui o arquivo fuctions.sh que contém as funções
source /home/ec2-user/efs/scripts/DISK/fuctions.sh

# Define o caminho do diretório onde os links simbólicos serão removidos
DIR_PATH="/home/ec2-user/efs/output/experiment_12/data/eopatch/processed"

# Verifica se o diretório existe
if [ ! -d "$DIR_PATH" ]; then
    echo "Directory '$DIR_PATH' does not exist."
    exit 1
fi

# Conta e exibe a quantidade de arquivos e links simbólicos antes da deleção
# echo "Before deletion:"
# count_files_and_links "$DIR_PATH"

# Remove os links simbólicos
remove_symlinks "$DIR_PATH"

# Conta e exibe a quantidade de arquivos e links simbólicos depois da deleção
# echo "After deletion:"
# count_files_and_links "$DIR_PATH"