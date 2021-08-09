#FROM python:3.7
# FROM python:3.8-slim
FROM ubuntu:20.04

RUN apt-get -y update && apt-get install -y python3 python3-pip
                
WORKDIR /btap
COPY requirements.txt /btap
RUN pip install -r requirements.txt
# #RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap


# removal due to security risk
#RUN apt-get remove -y libc-bin 

#COPY download_data.py download_data.py
RUN chmod a+x download_data.py

#ENTRYPOINT ["python", "download_data.py"]