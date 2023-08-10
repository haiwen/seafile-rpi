#!/bin/bash

#this script deletes all build containers, running containers and volumes
#this includes also the volumes that might not be related to build containers
#so be carefull it is meant to clean up and reclaim space

docker kill $(docker container ls -q) >> /dev/null 2>&1
docker builder rm multiarch_builder
docker container prune -f
docker builder prune -a -f
docker system prune -a -f
docker volume prune -a -f

