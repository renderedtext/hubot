# Hubot

SHELL=/bin/bash

.PHONY: build push

build:
	docker/build.sh

push:
	docker/tag.sh | xargs docker/push.sh

deploy:
	docker/tag.sh | xargs k8s/deploy.sh
