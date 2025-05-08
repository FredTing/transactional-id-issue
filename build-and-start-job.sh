#!/bin/bash
VERSION=${1}
mvn clean package -P flink1.20

FLINK_VERSION="$(mvn help:evaluate --quiet -DforceStdout -Dexpression=flink.version)"
KAFKA_CONNECTOR_VERSION="$(mvn help:evaluate --quiet -DforceStdout -Dexpression=flink-connector-kafka.version)"

echo "CONFLUENT_PLATFORM_VERSION=7.6.2" > .env
echo "DOCKER_REGISTRY=docker.io" >> .env
echo "FLINK_VERSION=${FLINK_VERSION}-java17" >> .env
echo "KAFKA_CONNECTOR_VERSION=${KAFKA_CONNECTOR_VERSION}" >> .env

# Stop the running containers
docker compose down

# Remove the existing volumes
docker volume rm $(docker volume ls -q | grep 'transactional-id')

#Build the docker images
docker compose build

# Start the containers again
docker compose up --build -d deploy init-kafka
