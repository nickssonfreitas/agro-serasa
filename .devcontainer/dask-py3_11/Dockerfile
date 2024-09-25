# Use a imagem base do Dask notebook com Python 3.11
FROM daskdev/dask-notebook:dev-py3.11

# Altere para o usuário root para ter permissões de instalação
USER root

# Instale pacotes adicionais do sistema, se necessário
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    # Copie o arquivo requirements-dev.txt para o contêiner
COPY requirements-dev.txt /workspace/requirements-dev.txt

# Copie o script start-notebook.sh para o contêiner
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
RUN chmod +x /usr/local/bin/start-notebook.sh

# Volte para o usuário padrão (jovyan é o usuário padrão na imagem dask-notebook)
USER jovyan

# Defina o diretório de trabalho padrão como /workspace
WORKDIR /workspace

# Exponha a porta padrão do JupyterLab
EXPOSE 8888

CMD ["/usr/local/bin/start-notebook.sh"]