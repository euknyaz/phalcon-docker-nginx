#!/bin/bash

mkdir -p magento
# curl -L https://s3.amazonaws.com/secretdelivery/magento2/Magento-CE-2.2.2-2017-12-11-09-21-15.tar.gz | tar -xC magento
docker build -t euknyaz/phalcon-docker-nginx-magento2 -f Dockerfile.magento2 .
docker push euknyaz/phalcon-docker-nginx-magento2
# rm -rf magento
