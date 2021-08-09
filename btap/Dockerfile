#FROM python:3.7
FROM python:3.8-slim

# create the pipeline directory
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

RUN mkdir -p /home/btap \
    && chown -R app /home/btap

USER 1000
#WORKDIR /btap
COPY requirements.txt /home/btap

RUN pip install -r requirements.txt
#RUN python3 -m pip install -r requirements.txt
COPY download_data.py /home/btap
