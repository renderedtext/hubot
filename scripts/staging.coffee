# Description:
#   Managment of staging servers
#
# Commands:
#   hubot stg conq stage_name - Conquers a staging server
#   hubot stg list - Lists the status of conquered servers
#   hubot stg release stage_name - Releases a conquered server

Util = require("util")

module.exports = (robot) ->

  robot.brain.data.staging = {
    stg1: "free",
    stg3: "free"
  }


  sender = (msg) ->
    msg.message.user.name.toLowerCase()

  exists = (stage) ->
    key of robot.brain.data.staging

  is_free = (stage) ->
    exists(stage) and robot.brain.data.staging[stage] == "free"

  conguer = (stage, user) ->
    robot.brain.data.staging[stage] = "conquered by #{user}"

  release = (stage) ->
    robot.brain.data.staging[stage] = "free"




  robot.respond /stg list$/i, (msg) ->
    response = "\n"
    for stage, value of robot.brain.data.staging
      response += "#{stage}: #{value}\n"

    msg.send(response)


  robot.respond /stg (c|conq) (.+)$/i, (msg) ->
    user  = sender(msg)
    stage = msg.match[2]

    if is_free(stage)
      conguer(stage, user)
      msg.send("#{stage} conquered by #{sender}")
    else
      msg.send("can't conquer #{stage}, it is #{robot.brain.data.staging[stage]}")


   robot.respond /stg (r|release) (.+)$/i, (msg) ->
    user = sender(msg)
    stage = msg.match[2]

    release(stage)
    msg.send("#{stage} released by #{user}")
