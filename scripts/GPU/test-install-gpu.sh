echo "Check GPU Capacity"
lspci | grep -i nvidia
echo "\nVerify Compilador GCC"
gcc --version
echo "\nCheck NVIDIA Driver"
nvidia-smi
echo "\nCheck Python Version"
python --version
echo "\nCheck CUDA and cuDNN Versions"
nvcc -V
