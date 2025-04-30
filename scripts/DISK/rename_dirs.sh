#!/bin/bash

# Define o caminho para o diretório principal
main_directory="/home/ec2-user/datasets/teste_pre_safra_2024_2025/eopatch_raw"

# Itera sobre todos os diretórios no diretório principal
for dir in "$main_directory"/*/; do
  # Obtém o nome do diretório
  dir_name=$(basename "$dir")
  
  # Remove o número e o primeiro '_' do nome do diretório
  new_dir_name=$(echo "$dir_name" | sed 's/^[0-9]*_//')
  
  # Renomeia o diretório
  mv "$main_directory/$dir_name" "$main_directory/$new_dir_name"
  
  echo "Renamed '$dir_name' to '$new_dir_name'"
done