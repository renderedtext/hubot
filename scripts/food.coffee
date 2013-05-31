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
  "Stevca"
  "Pub"
  "Djordjevic"
  "Kontejner"
  "Giros"
  "Kina"
]

module.exports = (robot) ->
  robot.respond /need food/i, (msg) ->
    msg.send msg.random restaurant
