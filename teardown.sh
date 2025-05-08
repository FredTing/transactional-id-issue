#!/bin/bash

# Stop the running containers
docker compose down

# Remove the existing volumes
docker volume rm $(docker volume ls --filter=name='^transactional-id' -q)

docker rmi $(docker images --filter=reference='flink-with-kafka' -q)

mvn clean