FROM python:3.8-slim
WORKDIR /btap
COPY requirements.txt /btap
RUN pip install -r requirements.txt
COPY download_data.py /btap
