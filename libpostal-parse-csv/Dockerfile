FROM wojtylacz/pypostal-docker

RUN pip3 install pandas
WORKDIR /home/parse
COPY input.csv /home/parse/input.csv
COPY parse_csv.py /home/parse/scripts/parse_csv.py
ENTRYPOINT [ "python3", \
            "/scripts/parse_csv.py", \
            "input.csv", \
            "address", \
            "output.csv" ]
