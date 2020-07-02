# https://github.com/Paperspace/fastai-docker/tree/master/fastai-v3
# GPU, ubuntu16.04
FROM paperspace/fastai:1.0-CUDA9.2-base-3.0-v1.0.6

# RUN apt-get update && apt-get install htop \
#            && apt-get clean \ 
#            && rm -rf /var/lib/apt/lists/*

ENV NB_PREFIX /
ENV PATH=$PATH:/opt/conda/bin
ENV USER fastai

RUN mkdir -p /home/jovyan && chmod -R a+w /home/jovyan/
WORKDIR /home/jovyan

# COPY requirements.txt install_requirements.sh /home/jovyan/
COPY requirements.txt install_requirements.sh /tmp/


# removal due to security risk
RUN apt-get remove -y libxml2
RUN rm -rf /notebooks

RUN bash -c '. activate fastai && pip install jupyterlab==2.1.5'

# "shell" form
# /tmp/install_requirements.sh
CMD /opt/conda/envs/fastai/bin/jupyter notebook --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}
