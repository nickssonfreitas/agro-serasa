#!/bin/bash

# Verificar se os parâmetros foram fornecidos
if [ "$#" -ne 3 ]; then
  echo "Uso: $0 <origem> <destino> <filtro>"
  exit 1
fi

# Caminho da pasta original
origem="$1"

# Caminho da pasta de destino
destino="$2"

# Filtro para os subdiretórios
filtro="$3"

# Encontrar e mover subdiretórios que correspondem ao filtro
find "$origem" -type d -name "$filtro" -exec rsync -av --remove-source-files {} "$destino" \;

# Remover diretórios vazios da origem
find "$origem" -type d -empty -delete

# Verificar se a operação foi bem-sucedida
if [ $? -eq 0 ]; then
  echo "Subdiretórios movidos com sucesso!"
else
  echo "Ocorreu um erro ao mover os subdiretórios."
fi
