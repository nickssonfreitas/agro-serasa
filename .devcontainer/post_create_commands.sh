#!/bin/bash

# Install agrilearn packages.
make install --directory=agrilearn

# NodeJS for better functioning of jupyter-lab extensions.
# https://saturncloud.io/blog/how-to-resolve-the-could-not-determine-jupyterlab-build-status-without-nodejs-error/
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install --yes nodejs

# Install python development tools after main dependencies.
pip install \
    jupyterlab \
    nodejs \
    jupyter-resource-usage \
    jupyterlab-geojson \
    ipywidgets \
    dask-labextension \
    pytest \
    pylint \
    ipdb \
    contextily

# Useful aliases.
echo "" >> /home/$USER_NAME/.bashrc && \
echo "# Useful aliases." >> /home/$USER_NAME/.bashrc && \
echo "alias openlab='jupyter-lab --ip=0.0.0.0 --no-browser --allow-root'" >> /home/$USER_NAME/.bashrc && \
source /home/$USER_NAME/.bashrc