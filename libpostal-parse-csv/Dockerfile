FROM wojtylacz/pypostal-docker

RUN pip3 install pandas
WORKDIR /home/parse
COPY input.csv input.csv
COPY parse_csv.py parse_csv.py
ENTRYPOINT [ "python3", \
            "parse_csv.py", \
            "input.csv", \
            "address", \
            "output.csv" ]
