FROM python:3.9.2-buster

COPY fibonacci-sum.py /home/fibonacci-sum.py
WORKDIR /home/
RUN chmod a+x /home/fibonacci-sum.py

ENTRYPOINT ["python3", "/home/fibonacci-sum.py"]
