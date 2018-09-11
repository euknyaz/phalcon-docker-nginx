#!/bin/bash

docker build -t euknyaz/phalcon-docker-nginx-redis-xdebug -f Dockerfile.xdebug .
docker push euknyaz/phalcon-docker-nginx-redis-xdebug
