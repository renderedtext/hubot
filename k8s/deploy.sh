#!/usr/bin/env bash

export image=$1

function install_gcloud {
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install -y google-cloud-sdk kubectl
  gcloud auth activate-service-account $SERVICE_ACCOUNT_NAME --key-file ~/service_account.json
  gcloud config set project semaphore-stg
  gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE
}

function create_deployment {
  kubectl apply -f /tmp/deploy.yml
  kubectl describe deployment hubot
}

echo ""
echo "Setting up gcloud"
echo "================="
echo ""

install_gcloud &> /dev/null

echo ""
echo "Rendering deploy.yml for image $(echo $image)"
echo "==================================================================="
echo ""

/usr/bin/env ruby <<-EORUBY
  require "erb"
  require "yaml"

  image = ENV.fetch("image")
  erb = ERB.new(File.read("deploy.yml.erb"))
  yml = YAML.load(erb.result(binding))
  File.write("/tmp/deploy.yml", yml.to_yaml)
EORUBY
cat /tmp/deploy.yml

echo ""
echo "Deploying to cluster"
echo "===================="
echo ""

create_deployment
