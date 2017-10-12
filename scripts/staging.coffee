# Description:
#   Managment of staging servers
#
# Commands:
#   list - Lists the status of conquered servers
#   flag <stage_name> - Flags a staging server
#   rel  <stage_name> - Releases a conquered server

Util = require("util")
moment = require("moment")

expireTime = 28800000



module.exports = (robot) ->

  robot.brain.data.staging = {}

  prettyDate = (date)->
    moment(date).fromNow()

  sender = (msg) ->
    msg.message.user.name.toLowerCase()

  room = (msg) ->
    msg.message.user.room

  exists = (stage) ->
    stage of robot.brain.data.staging

  is_free = (stage) ->
    expired = (Date.now() - robot.brain.data.staging[stage].date) > expireTime
    (exists(stage) and robot.brain.data.staging[stage].status == "free") or expired

  staging_list = () ->
    for stage_name, stage of robot.brain.data.staging
      title: stage_name
      value: (if is_free(stage_name) then "free" else stage.user)
      short: true

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



  robot.hear /^(list|ls)$/i, (msg) ->
    return unless room(msg) == "staging"
    response =
      attachments: [
        {
          text: ""
          fallback: "Ada list staging"
          pretext: ""
          color: "good"
          fields: staging_list()
        }
      ]
    console.log(staging_list())
    console.log(response)
    msg.send(response)



  robot.hear /^flag (.+)$/i, (msg) ->
    return unless room(msg) == "staging"

    user  = sender(msg)
    stage = msg.match[1]

    if exists(stage) and is_free(stage)
      conquer(stage, user)
      msg.send "*#{stage}* flagged"
    else if exists(stage)
      owner = robot.brain.data.staging[stage].user
      msg.send("#{owner} already flagged #{stage}")
    else
      msg.send("stage #{stage} does not exist")


  robot.hear /^rel (.+)$/i, (msg) ->
    return unless room(msg) == "staging"

    user  = sender(msg)
    stage = msg.match[1]

    if exists(stage)
      release(stage)
      msg.send "*#{stage}* released"
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


  robot.hear /^help$/i, (msg) ->
    return unless room(msg) == "staging"

    help = [
      "> *BASICS*"
      "> "
      "> *help* - Shows this help"
      "> *ls*   - Lists all stages"
      "> "
      "> *flag* <name> - Flag a stage"
      "> *rel*  <name> - Releases a stage"
      "> "
      "> *STAGE MANAGMENT*"
      "> "
      "> *stg add <name>* - Adds a new stage"
      "> *stg remove <name>* - Removes a stage"
      "> *stg --reset* - Removes all stages"
      "> "
      "> *Note*: your flag will automatically expire after 8 hours"
    ]

    msg.send(help.join("\n"))
