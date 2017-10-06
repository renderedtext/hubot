FROM node:8.6-slim

WORKDIR /app

ADD . /app

RUN npm install

CMD bin/hubot -a slack -n ada
