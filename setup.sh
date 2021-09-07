#!/bin/bash

# build the sparky image
docker build -t sparky-image .

# create sparky volume for persistence
docker volume create sparky-vol

# start container
if $1
then
docker run -d \
       	--name $1 \
	--mount source=sparky-vol,target=/notebooks \ 
	sparky-image 
else
docker run -d \
	--name spary
	--mount source=sparky-vol,target=/notebooks \ 
	sparky-image 
fi
