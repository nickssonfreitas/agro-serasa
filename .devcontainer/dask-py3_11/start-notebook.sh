#!/bin/bash

# Diretório onde os notebooks serão armazenados (defina o caminho desejado)
NOTEBOOK_DIR=${NOTEBOOK_DIR:-/workspace}

# Verifique se o diretório de notebooks existe, se não, cria o diretório
if [ ! -d "$NOTEBOOK_DIR" ]; then
    mkdir -p "$NOTEBOOK_DIR"
fi

# Defina as configurações de execução do JupyterLab (sem token ou senha)
LAB_ARGS="--no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.token='' --NotebookApp.password='' --notebook-dir=$NOTEBOOK_DIR"

# Inicia o JupyterLab
echo "Starting JupyterLab in directory: $NOTEBOOK_DIR"
exec jupyter lab $LAB_ARGS
