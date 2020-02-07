FROM ubuntu:latest

LABEL maintainer="litong01@us.ibm.com"

RUN apt update -y                                     && \
    apt install -y software-properties-common curl    && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt install -y apt-transport-https ca-certificates gnupg-agent && \
    apt install -y ansible docker-ce docker-ce-cli containerd.io

COPY . /home
COPY plugins /usr/lib/python2.7/dist-packages/ansible/plugins
RUN find /home/plugins -delete
ENV PATH $PATH:/home/bin
WORKDIR /home
