FROM alpine:latest

LABEL maintainer="litong01@us.ibm.com"

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache bash ansible docker-cli openssl xxd && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    mkdir -p /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna

COPY . /home
COPY plugins /usr/lib/python3.8/site-packages/ansible/plugins
COPY pypatch /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna
RUN find /home/plugins -delete && find /home/pypatch -delete

ENV PATH $PATH:/home/bin
WORKDIR /home