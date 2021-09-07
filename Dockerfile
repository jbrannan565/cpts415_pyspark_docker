#Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="jared.brannan@wsu.edu"
LABEL version="0.1"
LABEL description="This is a docker image for running a \
pyspark env for cpts 415 fall 2021 at wsu"

# Update Ubuntu Software repository
RUN apt update

# install ssh net tools java and python
RUN apt install openssh-server net-tools openjdk-11-jre-headless python3-pip -y

# start ssh
RUN service ssh start

# add user
RUN useradd -m sparky
RUN usermod -aG sudo sparky
USER sparky
RUN echo $HOME

# generate sshkey for pyspark
RUN ssh-keygen -f $HOME/.ssh/spark_rsa -N ""

# add key to own authorized keys
RUN cat $HOME/.ssh/spark_rsa.pub >> $HOME/.ssh/authorized_keys

# download an unzip pyspark
RUN cd $HOME
RUN wget "https://www.apache.org/dyn/closer.lua/spark/spark-3.0.3/spark-3.0.3-bin-hadoop3.2.tgz"
RUN tar -zxvf spark-3.0.3-bin-hadoop3.2.tgz

# run spark cluster
RUN $HOME/spark-3.0.3-bin-hadoop3.2/sbin/start-all.sh

# install python deps
RUN pip3 install pyspark==3.0.3 notebook pandas jupyterlab

# add notebook to PATH
RUN echo "PATH=\$PATH:/home/ubuntu/.local/bin" >> $HOME/.bashrc

# add pyspark env vars
RUN echo "export SPARK_HOME=$HOME/spark-3.0.3-bin-hadoop3.2" >> $HOME/.bashrc
RUN echo "export PYTHONPATH=$HOME/spark-3.0.3-bin-hadoop3.2/PYTHON" >> $HOME/.bashrc

# update env
RUN source $HOME/.bashrc

# start jupyter lab
RUN jupyter lab &

EXPOSE 8080 8888
