
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
- **Python:** Python 3.11 (managed via `pyenv`).
- **System Dependencies:** Required packages like `libgdal`, `libproj`, `gcc`, etc.
- **pyenv:** For managing multiple Python versions.

## Setting Up the Development Environment
Follow these steps to set up your development environment:

### 1. Clone the Repository
```bash
git clone https://github.com/nickssonfreitas/agro-serasa
cd agro-serasa
```

### 2. Create a Development Branch
```bash
git fetch origin && \
git checkout -b develop origin/develop || \
git checkout -b develop
```

### 3. Create a `.env` File
Create a `.env` file in the project root with the following content:
```env
PROJECT_PATH=<YOUR_PATH_TO_PROJECT>
DATASETS_PATH=<YOUR_PATH_TO_DATASETS>
SENTINEL_HUB_CLIENT_ID=<YOUR_PATH_TO_SENTINEL_HUB_CLIENT_ID>
SENTINEL_HUB_CLIENT_SECRET=<YOUR_PATH_TO_SENTINEL_HUB_CLIENT_SECRET>
```

### 4. Clone the repository eo-learn to get data in other directory
The eoc-learn is a repository very big, then, I recomend you pull only the last commit using HTTPs
```bash
git clone --depth 1 https://github.com/sentinel-hub/eo-learn.git # get most recent commit (this repositoty is very big)
```
If you failed, then you can increase the HTTP buffet using the command below.
```bash
git config --global http.postBuffer 524288000 #increase buffet size HTTP to download
```

If you failed, then you can try uses git protocol.
```bash
git clone git://github.com/sentinel-hub/eo-learn.git
```

### 5. Create a venv python using install-venv.md


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

## Data
The EOPatches under `data/eopatches/` and the generated EOPatches under `data/outputs/` (~9.6 GB)
are not versioned in this repository. They were removed from the git history on 2026-09-30 to free
the GitHub Git LFS quota. A full backup of the original repository, including every LFS object, is
kept in the maintainer's Google Drive (`Backups GitHub - agro-serasa (2026-09-30)`); ask the
maintainer for access, or regenerate the EOPatches with the notebooks in `notebooks/`.
