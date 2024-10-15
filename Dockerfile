FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu20.04

WORKDIR /root

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.10.14
ENV CUB_VERSION=1.10.0
ENV CUB_HOME=/workspace/cub-${CUB_VERSION}

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*


# Configurar Python y pip
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    python3 -m pip install --upgrade pip


# Establecer el directorio de trabajo
WORKDIR /usr/local/src

# Descargar e instalar NVIDIA CUB 1.10.0
RUN curl -LO https://github.com/NVIDIA/cub/archive/${CUB_VERSION}.tar.gz && \
    tar xzf ${CUB_VERSION}.tar.gz && \
    export CUB_HOME=$PWD/cub-${CUB_VERSION}

# Instalar PyTorch y torchvision con CUDA 12.1
WORKDIR /usr/local/src
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

WORKDIR /root
# Copiar el archivo requirements.txt al contenedor
COPY requirements/vggsfm.txt /root/requirements/vggsfm.txt

# Instalar dependencias desde el archivo requirements.txt
RUN pip install -r requirements/vggsfm.txt

WORKDIR /root
# Instalar LightGlue (opcional)
RUN git clone https://github.com/jytime/LightGlue.git dependency/LightGlue && \
    cd dependency/LightGlue && \
    python -m pip install -e .

# Clonar el repositorio de PyTorch3D
RUN git clone https://github.com/facebookresearch/pytorch3d.git /root/pytorch3d

# Cambiar al directorio de PyTorch3D y realizar la instalación en modo editable
WORKDIR /root/pytorch3d
RUN pip install -e .
