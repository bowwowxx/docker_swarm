clean-machine:
	- docker-machine rm -f -y swarm-master
	- docker-machine rm -f -y swarm-node1
	- docker-machine rm -f -y google-keystore

create-machine-keystore:
	docker-machine create \
    --driver google \
		--google-machine-type n1-standard-1 \
		--google-zone asia-east1-a \
    --google-disk-size 20 \
    google-keystore

run-consul:
	docker run -d \
	  -p "8500:8500" \
	  -h "consul" \
	  progrium/consul -server -bootstrap

create-machine-swarm-master:
  docker-machine create \
   --driver google \
   --google-machine-type n1-standard-1 \
   --google-zone asia-east1-a \
   --google-disk-size 20 \
   --swarm-master \
   --swarm \
   --swarm-discovery="consul://$(docker-machine ip google-keystore):8500" \
   --engine-opt="cluster-store=consul://$(docker-machine ip google-keystore):8500" \
   --engine-opt="cluster-advertise=eth0:2376" \
   swarm-master

create-machine-swarm-node:
 docker-machine create \
  --driver google \
  --google-machine-type n1-standard-1 \
  --google-zone asia-east1-a \
  --google-disk-size 20 \
  --swarm --swarm-image="swarm" \
  --swarm-discovery="consul://$(docker-machine ip google-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip google-keystore):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  swarm-node1

create-network-overlay:
 docker network create --driver overlay cloud-overlay

run-sample-server:
 docker run -itd --name=web --net=cloud-overlay --env="constraint:node==google-master" nginx

run-sample-client:
 docker run -it --net=cloud-overlay --env="constraint:node==google-node" busybox wget -O- http://web

run-by-compose:
 docker-compose --x-networking --x-network-driver overlay up -d
