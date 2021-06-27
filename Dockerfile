FROM alpine:3.13

LABEL maintainer="litong01@us.ibm.com"

ENV PYTHONUNBUFFERED=1

RUN apk add --update py-pip bash docker-cli openssl xxd dos2unix py3-cryptography && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    mkdir -p /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna \
             /usr/lib/python3.8/site-packages/ansible/plugins

COPY . /home
COPY plugins /usr/lib/python3.8/site-packages/ansible/plugins
COPY pypatch /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna
RUN rm -rf /var/cache/apk/* && rm -rf /tmp/* && apk update && \
    pip install requests google-auth kubernetes ansible && \
    ansible-galaxy collection install cloud.common kubernetes.core && \
    dos2unix -q /home/main.sh /home/scripts/mainfuncs.sh \
    /usr/lib/python3.8/site-packages/ansible/plugins/callback/minifab.py && \
    apk del dos2unix && rm -rf /var/cache/apk/* && rm -rf /tmp/*

ENV PATH $PATH:/home/bin
WORKDIR /home
