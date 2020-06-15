FROM k8scc01covidacr.azurecr.io/ml-workspace-geomatics:d81c6b205139f12a03b94fd2e407b3d796eebfff

# my code here...

# for development purposes run as root. Remove before pull request.
USER root
RUN apt-get update && apt-get install -y software-properties-common --no-install-recommends \
            && apt-get clean \ 
            && rm -rf /var/lib/apt/lists/*
USER jovyan

COPY requirements.txt /home/jovyan
COPY install_requirements.sh /home/jovyan
RUN /bin/bash -c "./install_requirements.sh"



CMD ["/init.sh"]