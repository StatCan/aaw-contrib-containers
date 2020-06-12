# https://github.com/Paperspace/fastai-docker/tree/master/fastai-v3
# GPU, ubuntu16.04
FROM paperspace/fastai:1.0-CUDA9.2-base-3.0-v1.0.6
RUN apt-get update && apt-get install -y software-properties-common --no-install-recommends \
            && apt-get clean \ 
            && rm -rf /var/lib/apt/lists/*
ENV NB_PREFIX /
ENV PATH=$PATH:/opt/conda/bin
ENV USER fastai
#RUN conda update -n base -c defaults conda && \
#    bash -c '. activate fastai && conda update -y fastai && \
#    conda install -c conda-forge rtree==0.9.4 gdal==3.1.0 && \
#    conda clean --all -f -y'

RUN /bin/bash -c ". activate fastai && conda update -y fastai"

RUN mkdir -p /home/jovyan && chmod -R a+w /home/jovyan
WORKDIR /home/jovyan

# removal due to security risk
RUN apt-get remove -y libxml2
RUN rm -rf /notebooks

COPY requirements.txt /home/jovyan
COPY install_requirements.sh /home/jovyan
#RUN ./install_requirements.sh

# Tanzania repo 
RUN git clone --depth=1 https://github.com/daveluo/zanzibar-aerial-mapping.git
CMD ["sh","-c", "./install_requirements.sh;", "/opt/conda/envs/fastai/bin/jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
