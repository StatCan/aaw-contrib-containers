FROM wojtylacz/pypostal-docker

RUN pip3 install pandas
WORKDIR /home/parse
COPY parse_csv.py parse_csv.py
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
USER $NB_USER
ENTRYPOINT [ "python3", \
            "parse_csv.py", \
            "input.csv", \
            "address", \
            "output.csv" ]
