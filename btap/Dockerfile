#FROM python:3.7
# FROM python:3.8-slim
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
                
WORKDIR /btap
COPY requirements.txt /btap
RUN pip install -r requirements.txt
COPY download_data.py /btap

#COPY download_data.py download_data.py
RUN chmod a+x download_data.py
CMD ["python", "download_data.py"] 