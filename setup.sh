#!/bin/bash

# build the sparky image
docker build -t sparky-image .

# create sparky volume for persistence
docker volume create sparky-vol

# start container
docker run -it --mount source=sparky-vol,target=/notebooks \
	--network host \
	sparky-image 
