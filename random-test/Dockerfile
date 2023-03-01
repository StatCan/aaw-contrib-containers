FROM python:slim-buster

COPY fibonacci-sum.py fibonacci-sum.py
RUN chmod a+x fibonacci-sum.py

ENTRYPOINT ["python", "fibonacci-sum.py"]