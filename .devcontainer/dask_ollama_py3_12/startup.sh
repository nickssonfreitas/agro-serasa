#!/bin/bash

set -e
set -x

#--------------------------------------------
#
# services.d
#
#--------------------------------------------

# the runtime directory must be a path that is NOT a persistent volume
# as volumes often cause permission issues https://github.com/jupyter/notebook/issues/5058
export JUPYTER_RUNTIME_DIR="/tmp/jupyter_runtime"

cd "${HOME}"
exec /opt/conda/bin/jupyter lab \
  --notebook-dir="${HOME}" \
  --ip=0.0.0.0 \
  --no-browser \
  --allow-root \
  --port=8888 \
  --ServerApp.token="" \
  --ServerApp.password="" \
  --ServerApp.allow_origin="*" \
  --ServerApp.allow_remote_access=True \
  --ServerApp.authenticate_prometheus=False \
  --ServerApp.base_url="${NB_PREFIX}"