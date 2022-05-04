FROM coinor/coin-or-optimization-suite:latest

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    davix-dev \
    dcap-dev \
    fonts-freefont-ttf \
    g++ \
    gcc \
    gfal2 \
    gfortran \
    git \
    libafterimage-dev \
    libavahi-compat-libdnssd-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libfreetype6-dev \
    libftgl-dev \
    libgfal2-dev \
    libgif-dev \
    libgl2ps-dev \
    libglew-dev \
    libglu-dev \
    libgraphviz-dev \
    libgsl-dev \
    libjemalloc-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    liblz4-dev \
    liblzma-dev \
    libmysqlclient-dev \
    libpcre++-dev \
    libpng-dev \
    libpq-dev \
    libpythia8-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtbb-dev \
    libtiff-dev \
    libx11-dev \
    libxext-dev \
    libxft-dev \
    libxml2-dev \
    libxpm-dev \
    libz-dev \
    libzmq3-dev \
    locales \
    lsb-release \
    make \
    openjdk-11-jdk \
    parallel \
    pkg-config \
    python3 \
    python3-dev \
    python3-markdown \
    python3-pip \
    python3-requests \
    python3-tk \
    python3-yaml \
    r-base \
    r-cran-rcpp \
    r-cran-rinside \
    rsync \
    srm-ifce-dev \
    unixodbc-dev \
    unzip \
    vim \
    wget \
    && \
    apt-get clean

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get update && apt-get install -y --no-install-recommends \
    glpk-utils      \
    libglpk-dev     \
    glpk-doc

RUN python3 -m pip --no-cache-dir install -U pip wheel setuptools

RUN python3 -m pip --no-cache-dir install \
    cbor \
    h5py \
    matplotlib \
    numpy \
    pandas \
    Pillow \
    scipy \
    sklearn

RUN python3 -m pip install -U pybind11 spdlog
RUN python3 -m pip install -U glpk
RUN python3 -m pip install -U pyomo
RUN python3 -m pip install -U PuLP
RUN python3 -m pip install -U simpy
RUN python3 -m pip install -U jupyterlab

RUN git clone https://github.com/jckantor/ND-Pyomo-Cookbook
RUN git clone https://github.com/Pyomo/PyomoGallery

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]

