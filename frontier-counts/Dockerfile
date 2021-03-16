FROM python:3.8.3-buster

ENV USER=app
ARG USER_GID=100
ENV APP_HOME=/home/app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN adduser --system --group $USER \
    && mkdir -p $APP_HOME \
    && chown -R $USER:$USER $APP_HOME

COPY src_requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt

USER $USER
