FROM node:0.10-slim

WORKDIR /app

ADD . /app

RUN npm install

CMD bin/hubot -a slack -n ada
