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
  robot.respond /I am hungry/i, (msg) ->
    msg.send msg.random restaurant
