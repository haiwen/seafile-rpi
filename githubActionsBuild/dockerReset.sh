#!/bin/bash

docker kill $(docker container ls -q)
docker builder rm multiarch_builder
docker container prune -f
docker builder prune -a -f
docker system prune -a -f
docker volume prune -a -f
