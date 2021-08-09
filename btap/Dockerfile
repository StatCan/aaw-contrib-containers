#FROM python:3.7
FROM python:3.8-slim


RUN apt-get -y update && apt-get install -y python && apt-get clean
                
WORKDIR /btap
COPY requirements.txt /btap
RUN pip install -r requirements.txt
# #RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap


# removal due to security risk
RUN apt-get remove -y libxml2 && apt-get remove -y libxml2-dev && apt-get remove -y libc6 && apt-get remove -y libc6-dev 

#COPY download_data.py download_data.py
RUN chmod a+x download_data.py

#ENTRYPOINT ["python", "download_data.py"]
