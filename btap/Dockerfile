FROM python:3.7

# create the pipeline directory
WORKDIR /btap
COPY requirements.txt /btap

USER jovyan
#RUN pip install -r requirements.txt
RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap
