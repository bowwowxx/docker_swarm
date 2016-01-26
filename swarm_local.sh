#!/bin/bash

set -e

docker-machine create \
    -d virtualbox \
    swl-consul

docker $(docker-machine config swl-consul) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

docker-machine create \
    -d virtualbox \
    --virtualbox-disk-size 50000 \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo0

docker-machine create \
    -d virtualbox \
    --virtualbox-disk-size 50000 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo1

docker-machine create \
    -d virtualbox \
    --virtualbox-disk-size 50000 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip swl-consul):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    swl-demo2

eval $(docker-machine env --swarm swl-demo0)
docker network create --driver overlay bowwow-net

docker run -itd --name=webtest --net=bowwow-net --env="constraint:node==swl-demo1" nginx
docker run -it --net=bowwow-net --env="constraint:node==swl-demo2" busybox wget -O- http://webtest
