#!/bin/bash

# build the sparky image
docker build -t sparky-image .

# create sparky volume for persistence
docker volume create sparky-vol

# start container
docker run -it \
	--mount source=sparky-vol,target=/notebooks \
	--ip=0.0.0.0 \
	-p 35565:8080 \
	-p 2222:22 \
	-p 80:8888 \
	sparky-image
