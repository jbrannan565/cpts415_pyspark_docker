#Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="jared.brannan@wsu.edu"
LABEL version="0.1"
LABEL description="This is a docker image for running a \
pyspark env for cpts 415 fall 2021 at wsu"

# disable interactive portions
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update Ubuntu Software repository
RUN apt update
RUN apt install sudo -y
RUN apt install wget -y

# install ssh net tools java python and sudo
RUN apt install openssh-server net-tools openjdk-11-jre-headless python3-pip -y

# install tmux
RUN apt install tmux -y

# add user
RUN useradd -m sparky
RUN passwd -d sparky
RUN usermod -aG sudo sparky
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# start ssh
RUN sudo service ssh start

EXPOSE 22

USER root
CMD ["sh", "/etc/init.d/ssh", "start"]

# change user
USER sparky

RUN echo "user added"

# generate sshkey for pyspark
RUN ssh-keygen -f $HOME/.ssh/spark_rsa -N ""

# add key to own authorized keys
RUN cat $HOME/.ssh/spark_rsa.pub >> $HOME/.ssh/authorized_keys

# TODO: this doesn't work, it seems. unable to connect
# download, unzip pyspark
# and run spark cluster
RUN cd "/home/sparky" \
   && wget "https://dlcdn.apache.org/spark/spark-3.0.3/spark-3.0.3-bin-hadoop3.2.tgz" \
   && tar zxvf spark-3.0.3-bin-hadoop3.2.tgz \
   && ./spark-3.0.3-bin-hadoop3.2/sbin/start-all.sh

# install python deps
RUN pip3 install pyspark==3.0.3 notebook pandas jupyterlab

# add notebook to PATH
ENV PATH="/home/sparky/.local/bin:${PATH}"

# add pyspark env vars
ENV SPARK_HOME="/home/sparky/spark-3.0.3-bin-hadoop3.2"
ENV PYTHONPATH="/home/sparky/spark-3.0.3-bin-hadoop3.2/PYTHON"

# start jupyter lab
EXPOSE 8080
EXPOSE 8888
RUN cd "/home/sparky"
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--notebook-dir", "/notebooks"]
