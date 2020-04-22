FROM continuumio/miniconda3

RUN apt-get update \
    && apt-get --yes install wget jq \
    && rm -rf /var/lib/apt/lists/*

# Default environment
RUN conda install --quiet --yes \
      -c conda-forge \
      "r-bayesplot" \
      "r-cowplot" \
      "r-data.table" \
      "r-dplyr" \
      "r-EnvStats" \
      "r-gdata" \
      "r-gdata"\
      "r-ggplot2" \
      "r-ggpubr" \
      "r-gridExtra" \
      "r-lubridate" \
      "r-matrixStats" \
      "r-readr" \
      "r-rstan" \
      "r-scales" \
      "r-tidyr" \
    && conda clean --all -f -y

RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && \
    mv mc /usr/bin/

COPY data    /data
COPY src     /src
COPY main.sh /main.sh

ENTRYPOINT ["/main.sh"]

