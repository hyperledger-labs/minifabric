FROM docker:latest
LABEL maintainer="litong01@us.ibm.com"
RUN apk add bash ansible python3
ADD https://raw.githubusercontent.com/dlitz/pycrypto/master/lib/Crypto/Random/Fortuna/FortunaGenerator.py \
    /usr/lib/python3.8/site-packages/Crypto/Random/Fortuna/FortunaGenerator.py

COPY . /home
ENV PATH $PATH:/home/bin
WORKDIR /home
