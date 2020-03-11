FROM alpine:latest

LABEL maintainer="litong01@us.ibm.com"

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache bash ansible docker-cli openssl xxd && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    wget -q https://raw.githubusercontent.com/dlitz/pycrypto/master/lib/Crypto/Random/Fortuna/FortunaGenerator.py \
    -O /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna/FortunaGenerator.py

COPY . /home
COPY plugins /usr/lib/python3.8/site-packages/ansible/plugins
RUN find /home/plugins -delete

ENV PATH $PATH:/home/bin
WORKDIR /home