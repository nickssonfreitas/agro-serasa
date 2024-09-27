#!/bin/bash
# Script for creating a local .env file with varibles used during building and / or running of docker containers.
# Example usage:
# source /home/ec2-user/efs/agrilearn/.devcontainer/template/docker_dev_envs.sh --agrilearn /home/ec2-user/efs/agrilearn --datasets /home/ec2-user/efs/agrilearn/datasets --weights /home/ec2-user/efs/agrilearn/weights --cache /home/ec2-user/efs/agrilearn/cache --ancillary_data /home/ec2-user/efs/agrilearn/ancillary_data --outputs /home/ec2-user/efs/agrilearn/outputs
# Example default usage:
# source /home/ec2-user/efs/agrilearn/.devcontainer/template/docker_dev_envs.sh --default
 
 
PROGRAM_NAME=$0
function usage {
    echo ""
    echo "Script for creating a local .env file with variables used during building and / or running of docker containers."
    echo ""
    echo "Usage Example: ${PROGRAM_NAME} [--agrilearn <path>] [--datasets <path>] [--weights <path>] [--cache <path>] [--ancillary_data <path>] [--outputs <path>]"
    echo "Usage Example: ${PROGRAM_NAME} [--help]"
    echo "Usage Example: ${PROGRAM_NAME} [-d]"
    echo ""
    echo "Options:"
    echo "    --agrilearn           string    Path to agrilearn main repository in the local host (maybe an EFS disk)"
    echo "                                    Example: /home/ec2-user/efs/repositories/agrilearn"
    echo "    --datasets            string    Path to datasets in the local host (must be in an EBS disk)"
    echo "                                    Example: /home/ec2-user/datasets"
    echo "    --weights             string    Path to trained models in the local host (must be in an EBS disk)"
    echo "                                    Example: /home/ec2-user/weights"
    echo "    --cache               string    Path to cache of eopatches in the local host (must be in an EBS disk)"
    echo "                                    Example: /home/ec2-user/cache"
    echo "    --ancillary_data      string    Path to ancillary_data of eopatches in the local host (must be in an EBS disk)"
    echo "                                    Example: /home/ec2-user/ancillary_data"
    echo "    --outputs             string    Path to the folder where the outputs (logs, output GPKG) will be saved"
    echo "                                    Example: /home/ec2-user/outputs"
    echo "    -h or --help                    Display this help message"
    echo "    -d or --default                 Use default paths for agrilearn, datasets, weights, cache, and outputs"
    echo ""
}
 
# When some of the parameters are missing.
function die {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}
 
while [ $# -gt 0 ]; do
    case $1 in
      # If --default was passed, use default parameters
      -d | --default)
        echo "Using default values for agrilearn paths..."
        agrilearn="/home/ec2-user/Git/agrilearn"
        datasets="/home/ec2-user/datasets"
        weights="/home/ec2-user/weights"
        cache="/home/ec2-user/cache"
        ancillary_data="/home/ec2-user/ancillary_data"
        outputs="/home/ec2-user/outputs"
        # create default directories
        mkdir -p $agrilearn
        mkdir -p $datasets
        mkdir -p $weights
        mkdir -p $cache
        mkdir -p $ancillary_data
        mkdir -p $outputs
        shift
        ;;
      # Support for help function.
      -h | --help)
        usage
        exit 0
        ;;
      # Parses all arguments and turns them into variables.
      --*)
        v="${1/--/}"
        declare "$v"="$2"
        shift 2
        ;;
      *)
        usage
        die "Unknown option $1"
    esac
done
 
# If one of the parameters is missing, display usage and terminate the script.
if [[ -z $agrilearn ]]; then
    usage
    die "Missing parameter --agrilearn"
elif [[ -z $datasets ]]; then
    usage
    die "Missing parameter --datasets"
elif [[ -z $weights ]]; then
    usage
    die "Missing parameter --weights"
elif [[ -z $cache ]]; then
    usage
    die "Missing parameter --cache"
elif [[ -z $ancillary_data ]]; then
    usage
    die "Missing parameter --ancillary_data"
elif [[ -z $outputs ]]; then
    usage
    die "Missing parameter --outputs"
fi
 
# Grep the version from pyproject.toml. Squeeze multiple spaces, delete double and single quotes, get 3rd val.
# This command tolerates multiple whitespace sequences around the version number.
VERSION=$(grep -m 1 version ${agrilearn}/pyproject.toml | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)
 
DEVCONTAINER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
 
echo "Saving .env at ${DEVCONTAINER_DIR}/.env"
 
cat << EOF > ${DEVCONTAINER_DIR}/.env
# Name for this image.
DOCKER_IMAGE_NAME=agrilearn_dev
 
# User name inside container.
USER_NAME=ec2-user
 
# Nexus server.
DOCKER_REGISTRY=registry.datalabserasaexperian.com.br
 
# Our folder in Nexus server.
REGISTRY_FOLDER=alternative_data
 
# Package version.
VERSION=${VERSION}
 
# Hostname.
HOST_NAME=altdatacontainer
 
# Agrilearn repository location in the host machine.
HOST_AGRILEARN=${agrilearn}
 
# Path to the datasets folder in the host machine.
HOST_DATASETS=${datasets}
 
# Path for the weights of the trained models in the host machine.
HOST_WEIGHTS=${weights}
 
# Path to the downloader cache folder in the host machine.
HOST_CACHE=${cache}
 
# Path to the ancillary data folder in the host machine.
HOST_ANCILLARY_DATA=${ancillary_data}

# Path to the downloader cache folder in the host machine.
HOST_OUTPUTS=${outputs}
 
# Path to the agrilearn model weights
AGRILEARN_WEIGHTS_PATH=/agrilearn_app/weights

# s3 bucket name of the private mirror with satellite image from Sentinel
SENTINEL_MIRROR_BUCKET_NAME=brain-alternative-data-imagery
EOF