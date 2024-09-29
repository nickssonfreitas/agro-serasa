# Use the official Gradle image with JDK 17 installed as the base image
FROM gradle:jdk17

# Update package lists and install the 'libgomp1' library
RUN apt-get update && apt-get install libgomp1 -y

# Set the working directory inside the container
WORKDIR /usr/app

# Define an argument for the JNI library path and copy the shared libraries (*.so files) to the 'libs' directory
ARG JNI_LIBRARY_PATH=jniLibs
COPY $JNI_LIBRARY_PATH/*.so libs/

# Set the LD_LIBRARY_PATH environment variable to include the 'libs' directory
ENV LD_LIBRARY_PATH=/usr/app/libs

# Copy the 'translator-cli' executable to the working directory
COPY build/install/translator-cli translator-cli

# Install Python 3 and the pip package manager
RUN apt install python3-pip -y

# Upgrade pip to the latest version
RUN pip install --upgrade pip

# Install JupyterLab and additional Python packages using pip

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 8888

WORKDIR $HOME

CMD ["sh", "-l", "-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]

#ENTRYPOINT ["translator-cli/bin/translator-cli"]