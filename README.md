
# Agro Serasa Project

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setting Up the Development Environment](#setting-up-the-development-environment)
3. [Project Structure](#project-structure)
4. [Important Links](#important-links)
5. [Troubleshooting](#troubleshooting)
6. [Additional Information](#additional-information)

## Prerequisites
- **Git:** Ensure `git` is installed for cloning the repository.
- **Python:** Python 3.9 or 3.12 (managed via `pyenv`).
- **System Dependencies:** Required packages like `libgdal`, `libproj`, `gcc`, etc.
- **pyenv:** For managing multiple Python versions.

## Setting Up the Development Environment
Follow these steps to set up your development environment:

### 1. Clone the Repository
```bash
git clone https://github.com/nickssonfreitas/agro-serasa
cd agro-serasa
```

### 2. Install System Dependencies
Install the necessary system packages:
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential libbz2-dev libncurses5-dev libncursesw5-dev \
    libreadline-dev libssl-dev libsqlite3-dev libffi-dev zlib1g-dev \
    wget liblzma-dev tk-dev gcc libgdal-dev graphviz proj-bin \
    libproj-dev libspatialindex-dev gdal-bin
```

### 3. Install and Configure `pyenv`
1. Install `pyenv`:
    ```bash
    curl https://pyenv.run | bash
    ```

2. Add the following lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`):
    ```bash
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    if command -v pyenv-virtualenv-init > /dev/null; then
      eval "$(pyenv virtualenv-init -)"
    fi
    ```

3. Apply the changes:
    ```bash
    source ~/.bashrc
    ```

### 4. Install Python Versions and Create Virtual Environment
1. Install Python versions:
    ```bash
    pyenv install 3.9.12
    pyenv install 3.12.3
    ```

2. Set up the virtual environment:
    ```bash
    pyenv shell 3.9.12
    python -m venv .venv3.9
    source .venv3.9/bin/activate
    ```

3. Install project dependencies:
    ```bash
    pip install --upgrade pip
    pip install -r requirements-dev.txt
    ```

### 5. Create a Development Branch
```bash
git branch developer
git checkout developer
git pull origin developer
```

### 6. Create a `.env` File
Create a `.env` file in the project root with the following content:
```env
PATH_TO_PROJECT=<YOUR_PATH_TO_PROJECT>
```

### 7. Clone the repository eo-learn to get data in other directory
The eoc-learn is a repository very big, then, I recomend you pull only the last commit using HTTPs
```bash
- git clone --depth 1 https://github.com/sentinel-hub/eo-learn.git # get most recent commit (this repositoty is very big)
```
If you failed, then you can increase the HTTP buffet using the command below.
```bash
- git config --global http.postBuffer 524288000 #increase buffet size HTTP to download
```

If you failed, then you can try uses git protocol.
```bash
- git clone git://github.com/sentinel-hub/eo-learn.git
```

## Project Structure
```plaintext
├── README.md          <- Project documentation and setup guide
├── data
│   ├── external       <- Data from third-party sources
│   ├── interim        <- Intermediate data that has been transformed
│   ├── processed      <- The final data sets for modeling
│   └── raw            <- Original, immutable data
│
├── docs               <- Project documentation
│
├── models             <- Trained and serialized models
│
├── notebooks          <- Jupyter notebooks for demonstrations
│
├── reports            <- Generated analysis and visualizations
│   └── figures        <- Generated graphics and figures
│
├── scripts            <- Project-specific scripts
│
├── requirements.txt   <- Python package requirements
│
├── src                <- Source code for the project
│   ├── api            <- API connections
│   ├── core           <- Core functionalities
│   ├── db             <- Database connections
│   ├── model          <- Machine learning models
│   ├── processing     <- Data preparation algorithms
│   ├── visualization  <- Visualization and dashboard creation
│   ├── __init__.py    <- Makes `src` a Python module
│
└── test               <- Unit tests
    ├── unit/          <- Unit tests
    ├── integration/   <- Integration tests
    ├── __init__.py    <- Makes `test` a Python module
```

## Important Links
- [Eo-learn Documentation](https://eo-learn.readthedocs.io/en/latest/)
- [Github EO-learn](https://github.com/sentinel-hub/eo-learn)
- [Generate setup.cfg from setup.py](https://github.com/asottile/setup-py-upgrade)
- [Python Packaging with setuptools](https://pythonhosted.org/an_example_pypi_project/setuptools.html)
- [Video Tutorial](https://www.youtube.com/watch?v=GaWs-LenLYE&t)

## Troubleshooting
- **GDAL Installation Issues:** If GDAL fails to install, ensure the correct version is installed:
    ```bash
    gdalinfo --version
    ```
- **Python Version Conflicts:** Ensure the virtual environment is activated and the correct Python version is being used.
- **pyenv Not Found:** Make sure `pyenv` is properly configured in your shell.

## Additional Information
For more details about contributing and advanced usage, see [CONTRIBUTING.md](CONTRIBUTING.md) and [docs](./docs).
