# https://github.com/Paperspace/fastai-docker/tree/master/fastai-v3
# GPU, ubuntu16.04
FROM paperspace/fastai:1.0-CUDA9.2-base-3.0-v1.0.6

RUN apt-get update && apt-get install -y software-properties-common --no-install-recommends \
            && apt-get clean \ 
            && rm -rf /var/lib/apt/lists/*

# RUN add-apt-repository ppa:ubuntugis/ppa && apt-get update

# gdal-bin and libgdal-dev is not installed because now gdal is installed with conda and hence these packages might not be required.
# RUN apt-get update && apt-get install -y python3-rtree gdal-bin libgdal-dev glances \
#           htop wget --no-install-recommends \ 
#           && apt-get clean \
#           && rm -rf /var/lib/apt/lists/*

# As Gdal is installed with conda the below code might not be required.
# ENV CPLUS_INCLUDE_PATH=/usr/include/
# ENV C_INCLUDE_PATH=/usr/include/

ENV NB_PREFIX /

ENV PATH=$PATH:/opt/conda/bin
ENV USER fastai

RUN conda update -n base -c defaults conda
RUN /bin/bash -c ". activate fastai && conda update -y fastai"
RUN /bin/bash -c ". activate fastai && pip install descartes==1.1.0 rio-tiler==1.4.0"
RUN /bin/bash -c ". activate fastai && pip install gpustat==0.6.0  mlflow==1.6.0 fastai==1.0.58 pigeon-jupyter==0.1.0 opencv-python==4.2.0.34 distro==1.4.0 scikit-image==0.16.2"
RUN /bin/bash -c ". activate fastai && conda install -c conda-forge rtree==0.9.4 gdal==3.1.0"
RUN /bin/bash -c ". activate fastai && pip install solaris==0.2.0 --ignore-installed PyYAML torchvision==0.5.0"

RUN mkdir -p /home/jovyan && chmod -R a+w /home/jovyan
WORKDIR /home/jovyan

# Tanzania repo 
RUN git clone https://github.com/daveluo/zanzibar-aerial-mapping.git

CMD ["sh","-c", "/opt/conda/envs/fastai/bin/jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]

