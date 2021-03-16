FROM ubuntu:20.04

ENV USER=app
ARG USER_GID=100
ENV APP_HOME=/home/app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN adduser --system --group $USER \
    && mkdir -p $APP_HOME \
    && chown -R $USER:$USER $APP_HOME

RUN apt-get update -y \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY src_requirements.txt /tmp/requirements.txt
RUN ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt

USER $USER
