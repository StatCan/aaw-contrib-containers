#FROM python:3.7
# FROM python:3.8-slim

# WORKDIR /btap
# COPY requirements.txt /btap

# RUN pip install -r requirements.txt
# #RUN python3 -m pip install -r requirements.txt
# COPY download_data.py /btap


FROM python:3.8-buster

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY download_data.py download_data.py
RUN chmod a+x download_data.py

ENTRYPOINT ["python", "download_data.py"]
