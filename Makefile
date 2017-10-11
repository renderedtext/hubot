# Hubot

SHELL=/bin/bash

.PHONY: build push

build:
	docker/build.sh

push:
	docker/tag | xargs docker/push.sh

deploy:
	docker/tag | xargs k8s/deploy.sh
