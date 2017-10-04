FROM node:8.6
MAINTAINER bmarkons, mbogdanovic@renderedtext.com

RUN mkdir /hubot
ADD . /hubot

CMD bin/hubot
