# Description:
#  Get random place for lunch.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   need food
#
# Author:
#   Rastko Jokic

restaurant = [
  "stevca"
  "pub"
  "djordjevic"
  "kontejner"
  "giros"
  "kina"
  "foody"
  "lipa"
  "bistro"
  "magaza"
  "crna maca"
]

module.exports = (robot) ->
  robot.respond /need food/i, (msg) ->
    msg.send msg.random restaurant
