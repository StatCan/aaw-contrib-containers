FROM python:3.7
RUN python3 -m pip install pandas
RUN python3 -m pip install StringIO
# create the pipeline directory
WORKDIR /btap
COPY requirements.txt /btap
#RUN pip install -r requirements.txt
RUN python3 -m pip install -r requirements.txt
COPY download_data.py /btap
