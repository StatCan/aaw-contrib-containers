#FROM python:3.7
FROM python:3.8-slim


USER 1000
WORKDIR /btap
COPY requirements.txt /btap

RUN pip install -r requirements.txt
#RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap
