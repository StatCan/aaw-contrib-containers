FROM python:3.9-alpine

RUN apk add wget openssh curl

ARG MC_RELEASE=mc.RELEASE.2020-06-20T00-18-43Z
ARG MC_SHA256=7198b0634f84c27e656bba527bf80ed048087e99afc7744e0fdd9e0790a726f5

RUN wget -O mc https://dl.min.io/client/mc/release/linux-amd64/archive/${MC_RELEASE} \
    && echo "${MC_SHA256}  mc" | sha256sum -c - \
    && chmod +x mc \
    && mv mc /bin

RUN pip install slack_sdk

RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

RUN mkdir -p /home/app \
    && chown -R app /home/app

USER 1000
