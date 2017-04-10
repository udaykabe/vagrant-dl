#!/usr/bin/env sh
 
#########################################
#  CREATE DOCKER NETWORKS AND VOLUMES   #
#########################################

echo "===== Docker networks ====="
echo "Created network nginx-proxy with id: `docker network create -d bridge nginx-proxy`"
echo "Created network back-tier with id: `docker network create -d bridge back-tier`"
echo "Created network nifi with id: `docker network create -d bridge nifi`"

echo "===== Docker volumes ====="
echo "Created volume: `docker volume create --name elasticsearch_data`"
echo "Created volume: `docker volume create --name docroot`"
echo "Created volume: `docker volume create --name redis_data`"
