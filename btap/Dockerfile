#FROM python:3.7
FROM python:3.8-slim

RUN apt-get update && apt-get install -y software-properties-common --no-install-recommends \
            && apt-get clean \ 
            && rm -rf /var/lib/apt/lists/*

WORKDIR /btap
COPY requirements.txt /btap

RUN pip install -r requirements.txt
#RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap
