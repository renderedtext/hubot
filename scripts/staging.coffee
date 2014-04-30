# Description:
#   Managment of staging servers
#
# Commands:
#   hubot stg conq stage_name - Conquers a staging server
#   hubot stg list - Lists the status of conquered servers
#   hubot stg release stage_name - Releases a conquered server

Util = require("util")
moment = require("moment")

expireTime = 28800000

module.exports = (robot) ->

  robot.brain.data.staging = {}

  prettyDate = (date)->
    moment(date).fromNow()

  sender = (msg) ->
    msg.message.user.name.toLowerCase()

  exists = (stage) ->
    stage of robot.brain.data.staging

  is_free = (stage) ->
    expired = (Date.now() - robot.brain.data.staging[stage].date) > expireTime
    (exists(stage) and robot.brain.data.staging[stage].status == "free") or expired

  conquer = (stage_name, user) ->
    stage = {}
    stage.status = "conquered"
    stage.user = user
    stage.date = Date.now()
    robot.brain.data.staging[stage_name] = stage

  release = (stage_name) ->
    stage = robot.brain.data.staging[stage_name]
    stage.status = "free"
    stage.user = ""
    stage.date = ""

  robot.hear /^stg (h|help|--help)/i, (msg) ->
    res = ""
    res += "*stg help* - Shows this help\n"
    res += "*stg list* - Lists all stages\n"
    res += "*stg conq* <name> - Conquares a stage\n"
    res += "*stg release* <name> - Releases a stage\n"
    res += "\nShortcuts\n"
    res += "*stg h* - Alias for help\n"
    res += "*stg l* - Alias for list\n"
    res += "*stg ls* - Alias for list\n"
    res += "*stg ls -lah* - Alias for list\n"
    res += "*stg c <name>* - Alias for conquer\n"
    res += "*stg r <name>* - Alias for release\n"
    res += "\nStage managment\n"
    res += "*stg add <name>* - Adds a new stage\n"
    res += "*stg remove <name>* - Removes a stage\n"
    res += "*stg --reset* - Removes all stages\n"
    res += "\n"
    res += "Note: your conquer will automatically expire after 8 hours"
    msg.send(res)

  robot.hear /stg (l|ls|ls -lah|list)$/i, (msg) ->
    response = "\n"
    for stage_name, stage of robot.brain.data.staging
      console.log(stage_name, is_free(stage_name))
      if is_free(stage_name)
        response += "*#{stage_name}*: :free:\n"
      else
        response += "*#{stage_name}*: #{stage.status} by *#{stage.user}* #{prettyDate(stage.date)}\n"

    msg.send(response)


  robot.hear /stg (c|conq) (.+)$/i, (msg) ->
    user  = sender(msg)
    stage = msg.match[2]

    if exists(stage) and is_free(stage)
      conquer(stage, user)
      msg.send("#{stage} conquered by #{user}")
    else if exists(stage)
      msg.send("can't conquer #{stage}, it is already conquered by #{robot.brain.data.staging[stage].user}")
    else
      msg.send("stage #{stage} does not exist")


   robot.hear /stg (r|release) (.+)$/i, (msg) ->
    user = sender(msg)
    stage = msg.match[2]

    if exists(stage)
      release(stage)
      msg.send("#{stage} released by #{user}")
    else
      msg.send("stage #{stage} does not exist")

   robot.hear /stg --reset/i, (msg) ->
     delete robot.brain.data.staging
     robot.brain.data.staging = {}
     msg.send("all stagings are now removed")

   robot.hear /stg add (.*)/i, (msg) ->
     stage_name = msg.match[1]

     if exists(stage_name)
       msg.send("stage already exists")
       return

     stage = robot.brain.data.staging[stage_name] = {}
     stage.status = "free"
     stage.user = ""
     stage.date = ""
     msg.send("stage #{stage_name} is added")

   robot.hear /stg remove (.*)/i, (msg) ->
     stage_name = msg.match[1]

     if not exists(stage_name)
       msg.send("stage does not exist")
       return

     delete robot.brain.data.staging[stage_name]
     msg.send("stage #{stage_name} is removed")
