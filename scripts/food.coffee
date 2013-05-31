# Description:
#   Richard Stallman Facts
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   I am hungry

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
