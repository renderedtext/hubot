# Description:
#   Pull Request processing system
#
# Commands:
#   hubot pr assign <PR-LINK> - Asks hubot to assign PR
#   hubot pr replace <USERNAME> - Replace user with the next one in rotation
#   hubot pr add <USERNAME> - Add user to rotation
#   hubot pr rm <USERNAME> - Remove user from rotation
#   hubot pr list - List all users in rotation, with time of last assignment


_ = require("lodash")
moment = require("moment")

class Rotation
  constructor: (@robot) ->
    @robot.brain.on("loaded", =>
      @users = []

      if @robot.brain.data.pr
        @users = _.map(@robot.brain.data.pr, (userData) ->
          new User(userData)
        )
        console.log("Loaded #{@users.length} users")
        console.log("Users #{JSON.stringify(@users)}")
    )

    @robot.brain.on("save", =>
      @robot.brain.data.pr = @users
    )

  find: (username) ->
    _.find(@users, {"username":username})

  exists: (username) ->
    _.some(@users, {"username":username})

  add: (username) ->
    user = new User({
      "username" : username,
      "lastPRTime": Date.now(),
      "lastPRUrl": ""
    })
    @users.push(user)

  remove: (username) ->
    _.remove(@users, { username: username })

  assign: (url, numberOfUsers, requestSender) ->
    potentialUsers = _.filter(@users, (user) =>
      user.username != requestSender
    )
    sortedUsers = _.sortBy(potentialUsers, ["lastPRTime"])

    _.map(_.take(sortedUsers, numberOfUsers), (user) ->
      user.assign(url)
      user
    )

  replace: (username) =>
    oldAssignee = @find(username)
    newAssignee = @assign(oldAssignee.lastPRUrl, 1, oldAssignee.username)
    oldAssignee.assign("-")
    _.first(newAssignee)

  toSlack: () ->
    _.map(@users, (user) -> user.toSlack())

class User
  constructor: (data) ->
    {@username, @lastPRTime, @lastPRUrl} = data

  toString: () ->
    @username

  assign: (url) ->
    @lastPRTime = Date.now()
    @lastPRUrl = url

  toSlack: () ->
    title: @username
    value: "#{@lastPRUrl} - #{moment(@lastPRTime).fromNow()}"
    short: true

class Controller
  constructor: (@robot) ->
    @rotation = new Rotation(robot)

  replace: (msg) =>
    username = msg.match[1]
    newAssignee = @rotation.replace(username)
    msg.send("Reassigned #{newAssignee.lastPRUrl} to #{newAssignee.toString()}")

  add: (msg) =>
    username = msg.match[1]

    if @rotation.exists(username)
      msg.send("User already exists")
      return

    @rotation.add(username)
    msg.send("User #{username} is successfully added")

  remove: (msg) =>
    username = msg.match[1]

    if not @rotation.exists(username)
      msg.send("User #{username} does not exist")
      return

    @rotation.remove(username)
    msg.send("User #{username} is successfully removed")

  listTxt: (msg) =>
    msg.send("Rotation: #{JSON.stringify(@rotation.toSlack())}")

  list: (msg) =>
    payload =
      message: msg.message
      content:
        text: ""
        fallback: "Fallback Text"
        pretext: ""
        color: "good"
        fields: @rotation.toSlack()

    @robot.emit "slack-attachment", payload

  assign: (msg) =>
    url = msg.match[1]
    sender = "@#{msg.message.user.name.toLowerCase()}"
    assignees =  @rotation.assign(url, 2, sender)

    msg.send("Assigned #{url} to #{assignees[0].toString()} and #{assignees[1].toString()}")

  help: (msg) =>
    description = """
      Description:
       Pull Request processing system

      Commands:
       hubot pr assign <PR-LINK> - Asks hubot to assign PR
       hubot pr replace <USERNAME> - Replace user with the next one in rotation
       hubot pr add <USERNAME> - Add user to rotation
       hubot pr rm <USERNAME> - Remove user from rotation
       hubot pr list - List all users in rotation, with time of last assignment
    """
    msg.send(description)

module.exports = (robot) ->
  ctrl = new Controller(robot)

  robot.respond /pr replace (.+)$/i, ctrl.replace
  robot.respond /pr add (.+)$/i, ctrl.add
  robot.respond /pr rm (.+)$/i, ctrl.remove
  robot.respond /pr list txt/i, ctrl.listTxt
  robot.respond /pr list/i, ctrl.list
  robot.respond /pr assign (.+)$/i, ctrl.assign
  robot.respond /pr help/i, ctrl.help
