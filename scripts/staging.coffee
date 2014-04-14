# Description:
#   Inspect the data in redis easily
#
# Commands:
#   hubot show users - Display all users that hubot knows about
#   hubot show storage - Display the contents that are persisted in the brain

Util = require("util")

module.exports = (robot) ->

  robot.brain.data.staging = {
    stg1: "empty",
    stg3: "empty"
  }

  robot.respond /stg list$/i, (msg) ->
    response = "\n"
    for stage, value of robot.brain.data.staging
      response += "#{stage}: #{value}\n"

    msg.send(response)

  robot.respond /stg conq (.+)$/i, (msg) ->
    sender = msg.message.user.name.toLowerCase()
    robot.brain.data.staging[msg.match[1]] = "conquered by #{sender}"
    msg.send("#{msg.match[1]} conquered by #{sender}")

   robot.respond /stg free (.+)$/i, (msg) ->
    sender = msg.message.user.name.toLowerCase()
    robot.brain.data.staging[msg.match[1]] = "empty"
    msg.send("#{msg.match[1]} released by #{sender}")
