# #!/bin/bash

# --------------------------------------------
# Script de Inicialização do Jupyter Lab
# --------------------------------------------

# Carrega as variáveis do arquivo .env se ele existir
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Imprime as variáveis PATH_PROJECT e PORT
echo "PATH_PROJECT: ${PATH_PROJECT}"
echo "JUPYTER_PORT: ${JUPYTER_PORT}"


# Definição de segurança e debug:
# `set -e` faz o script sair imediatamente se algum comando falhar.
# `set -x` mostra cada comando sendo executado, útil para debug.
set -e
set -x


# --------------------------------------------
# Definição das Configurações do Jupyter Lab
# --------------------------------------------
# O comando abaixo inicia o Jupyter Lab com várias configurações para controlar como ele deve ser acessado e utilizado.
# Executa o Jupyter Lab com as opções especificadas para atender às necessidades de ambientes Docker ou servidores remotos.

exec jupyter lab 
  --notebook-dir="${PATH_PROJECT}" \
  --ip=0.0.0.0 \
  --allow-root \
  --port="${JUPYTER_PORT}" \
  --ServerApp.token="" \
  --ServerApp.password="" \
  --ServerApp.allow_origin="*" \
  --ServerApp.allow_remote_access=True \
  --ServerApp.authenticate_prometheus=False \
  --ServerApp.base_url="${PROJECT_PATH}"

# --------------------------------------------
# Explicação das Opções de Configuração:
# --------------------------------------------
# --notebook-dir="${HOME}":
#   Define o diretório inicial dos notebooks como o diretório home do usuário.
#   Por exemplo, se o usuário for `jovyan`, o diretório será `/home/jovyan`.
#
# --ip=0.0.0.0:
#   Faz com que o Jupyter Lab escute em todos os endereços IP disponíveis.
#   Isso é necessário para tornar o Jupyter acessível de fora do contêiner ou servidor.
#
# --no-browser:
#   Impede a abertura automática de um navegador quando o Jupyter Lab inicia.
#   É útil em ambientes de linha de comando ou sem interface gráfica.
#
# --allow-root:
#   Permite a execução do Jupyter Lab como usuário `root`.
#   Normalmente, o Jupyter emite avisos ao rodar como `root`, mas essa opção suprime esses avisos.
#
# --port=8888:
#   Define a porta onde o Jupyter Lab será servido. A porta padrão é `8888`.
#
# --ServerApp.token="":
#   Desativa o uso de um token de autenticação para acessar o Jupyter.
#   Essa configuração é útil para desenvolvimento, mas **não deve ser usada em produção** sem medidas de segurança adicionais.
#
# --ServerApp.password="":
#   Desativa a necessidade de senha para acessar o Jupyter Lab.
#   Similar ao `token`, útil para ambientes de desenvolvimento.
#
# --ServerApp.allow_origin="*":
#   Permite acesso de qualquer origem (qualquer domínio).
#   Útil para permitir o acesso de diferentes máquinas, mas **pode representar um risco de segurança**.
#
# --ServerApp.allow_remote_access=True:
#   Permite acesso remoto ao Jupyter Lab. Necessário para ambientes Docker ou servidores.
#   Deve ser configurado corretamente para impedir acesso não autorizado.
#
# --ServerApp.authenticate_prometheus=False:
#   Desativa a autenticação para o endpoint de métricas do Prometheus.
#   Usado para permitir o monitoramento sem necessidade de autenticação adicional.
#
# --ServerApp.base_url="${NB_PREFIX}":
#   Define o URL base para o Jupyter Lab usando a variável de ambiente `NB_PREFIX`.
#   Útil quando o Jupyter Lab é acessado a partir de um subcaminho (ex: `http://localhost:8888/jupyter/`).
