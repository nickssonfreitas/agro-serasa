#!/bin/bash

# Lista de diretórios a serem verificados
diretorios=(
    "/home/ec2-user/datasets/base/eopatch/input_model/"
    "/home/ec2-user/datasets/teste_pre_safra_2024_2025/eopatch/input_model/"
)

# Lista de diretórios a serem verificados
arquivos=(
    "/home/ec2-user/efs/output/experiment_01/predictions/base/test/"
    "/home/ec2-user/efs/output/experiment_01/predictions/base/val/"
    "/home/ec2-user/efs/output/experiment_01/predictions/teste_pre_safra_2024_2025/test/"
    "/home/ec2-user/efs/output/experiment_01/results/teste_pre_safra_2024_2025/test/"
)

# Profundidade máxima
maxdepth=1

# Iterar sobre cada diretório na lista
for diretorio in "${diretorios[@]}"; do
    if [ -d "$diretorio" ]; then
        # Contar a quantidade de arquivos
        quantidade_arquivos=$(find "$diretorio" -maxdepth "$maxdepth" -type d | wc -l)
        # Exibir o resultado
        echo "Quantidade de diretório $diretorio com profundidade máxima de $maxdepth: $quantidade_arquivos"
    else
        echo "Diretório $diretorio não encontrado."
    fi
done

# Iterar sobre cada diretório na lista
for arquivo in "${arquivos[@]}"; do
    if [ -d "$diretorio" ]; then
        # Contar a quantidade de arquivos
        quantidade_arquivos=$(find "$arquivo" -maxdepth "$maxdepth" -type f | wc -l)
        # Exibir o resultado
        echo "Quantidade de arquivos no diretório $arquivo com profundidade máxima de $maxdepth: $quantidade_arquivos"
    else
        echo "Arquivos $arquivo não encontrado."
    fi
done
