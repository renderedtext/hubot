#!/usr/bin/env bash

function install_vbox {
  if [ "$OSTYPE" = "linux-gnu" ]; then
    sudo apt-get install virtualbox
  else
    brew cask install virtualbox
  fi
}

function install_kubectl {
  if [ "$OSTYPE" = "linux-gnu" ]; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl
  else
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/darwin/amd64/kubectl
  fi

  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
}

function install_minikube {
  if [ "$OSTYPE" = "linux-gnu" ]; then
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.22.3/minikube-linux-amd64
  else
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.22.3/minikube-darwin-amd64
  fi

  chmod +x minikube
  sudo mv minikube /usr/local/bin/
}

function check_vbox {
  if ! (which vboxmanage > /dev/null); then
    install_vbox
  fi
}

function check_kubectl {
  if ! (which kubectl > /dev/null); then
    install_kubectl
  fi
}

function check_minikube {
  if ! (which minikube > /dev/null); then
    install_minikube
  fi

  minikube_status=$(minikube status | head -n 1)

  if [ "$minikube_status" = "minikube: Stopped" ]; then
    minikube start
  fi
}

check_vbox
check_kubectl
check_minikube

kubectl apply -f minikube.yml --validate=false
