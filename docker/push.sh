#!/usr/bin/env bash

echo "Tagging latest hubot image"
docker tag "hubot:latest" $1
echo "Image $1"

echo "Pushing image to DockerHub"

docker push $1
echo "Image pushed $1"
