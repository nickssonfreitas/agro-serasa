#!/bin/bash
set -e

WORKDIR="/agrilearn_app"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Inicia o JupyterLab diretamente
exec jupyter lab --ip=0.0.0.0 --port=8890 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.allow_origin='*'