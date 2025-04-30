sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/12.4/x86_64/cuda-12..repo

#wget https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda_12.6.3_560.35.05_linux.run
#sudo mkdir -p /temp_cuda
#sudo sh CC=/usr/bin/gcc10-cc cuda_12.6.3_560.35.05_linux.run --tmpdir=/temp_cuda

# wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
# sudo dpkg -i cuda-keyring_1.1-1_all.deb
# sudo yum update
# sudo yum -y install cudnn
# sudo yum -y install cudnn-cuda-12