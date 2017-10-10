#!/usr/bin/env bash

echo "Rendering deploy.yml..."
/usr/bin/env ruby <<-EORUBY
  require "erb"
  require "yaml"

  image = ERB.fetch("image")
  erb = ERB.new(File.read("deploy.yml.erb"))
  yml = YAML.load(erb.result(binding))
  File.write("/tmp/deploy.yml", yml.to_yaml)
EORUBY

echo "Installing gcloud..."
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y google-cloud-sdk kubectl

echo "Setting up gcloud..."
gcloud auth activate-service-account $SERVICE_ACCOUNT_NAME --key-file ~/service_account.json
gcloud config set project semaphore-stg

echo "Setting up kubectl..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE

echo "Deploying to cluster..."
kubectl apply -f /tmp/deploy.yml
kubectl describe deployment hubot
