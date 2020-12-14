FROM wojtylacz/pypostal-docker

RUN pip3 install pandas

COPY parse_csv.py scripts/parse_csv.py
ENTRYPOINT [ "python3", \
            "/scripts/parse_csv.py", \
            "input.csv", \
            "address", \
            "output.csv" ]
