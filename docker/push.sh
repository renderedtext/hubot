#!/usr/bin/env bash

if [ -z $REVISION ]; then
  REVISION=$(git rev-parse --short HEAD)
fi

if [ -z $SEMAPHORE_JOB_UUID ]; then
  id="localbuild"
else
  id="${SEMAPHORE_JOB_UUID:0:8}"
fi

image="renderedtext/hubot:${REVISION:0:8}-${id}"

echo "Tagging latest hubot image"
docker tag "hubot:latest" $image
echo "Image $image"

echo "Pushing image to DockerHub"

docker push $image

echo "Image pushed $image"

/usr/bin/env ruby <<-EORUBY
  require "erb"
  require "yaml"

  image = "`echo $image`"
  erb = ERB.new(File.read("deploy.yml.erb"))
  yml = YAML.load(erb.result(binding))
  File.write("deploy.yml", yml.to_yaml)
EORUBY
echo "deploy.yml created"
