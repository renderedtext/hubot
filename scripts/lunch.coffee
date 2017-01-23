# Description:
#   Find random place near your office, get your lunch or drink location idea in second.
#
# Dependencies:
#   "https"
#
# Configuration:
#   FOURSQUARE_CLIENT_ID
#   FOURSQUARE_CLIENT_SECRET
#
# Commands:
#   hubot lunch - Returns a random lunch location
#
#   TODO:
#   hubot drink - Returns a random drink location
#
# Author:
#   rastasheep

client_id = process.env.FOURSQUARE_CLIENT_ID
client_secret = process.env.FOURSQUARE_CLIENT_SECRET

category_food = '4d4b7105d754a06374d81259'
category_drink = '4d4b7105d754a06376d81259'

location= '45.257217,19.845845'

https = require 'https'

module.exports = (robot) ->

  robot.brain.data.lunch = {}

  is_brain_empty = () ->
    for x,y of robot.brain.data.lunch
      return false
    return true

  room = (msg) ->
    msg.message.user.room

  location_exists = (location) ->
    location of robot.brain.data.lunch

  lunch_list = () ->
    console.log robot.brain.data.lunch
    for location, users of robot.brain.data.lunch
      users_for_location = ""
      for user, i in users
        users_for_location += user.name
        users_for_location += "\n"
      title: location
      value: users_for_location
      short: false

  add_user_on_location = (msg) ->
    location = msg.match[1]
    if(!location_exists(location))
      msg.send("Unknown location")
      return

    #sender = msg.message.user
    sender =
      name: msg.match[2]
    remove_user_from_location(sender)
    robot.brain.data.lunch[location].push sender

  remove_user_from_location = (sender) ->
    for loc, users of robot.brain.data.lunch
      for user, i in users
        if user.name == sender.name
          users.splice(i, 1)
          return

  robot.respond /lunch/i, (msg) ->
    search_for_venue (venue) ->
      venue.url = "https://foursquare.com/v/#{venue.id}"
      msg.send "We're having lunch at #{venue.name}: #{venue.url}"

  robot.hear /^(list|ls)$/i, (msg) ->
    return unless room(msg) == "lunch"

    if(is_brain_empty())
      msg.send("My lunch list is empty :white_frowning_face:")
      return

    payload =
      message: msg.message
      content:
        text: ""
        fallback: "Fallback Text"
        pretext: "Today's lunch distribution"
        color: "good"
        fields: lunch_list()
    robot.emit "slack-attachment", payload

  robot.hear /location add (.*)/i, (msg) ->
    location = msg.match[1]

    if(location_exists(location))
      msg.send("Location already exists")
      return

    robot.brain.data.lunch[location] = []

  robot.hear /location remove (.*)/i, (msg) ->
    location = msg.match[1]

    if(!location_exists(location))
      msg.send("You know something I don't?:scream: I don't have `#{location}` on my list.")
      return

    delete robot.brain.data.lunch[location]
    msg.send("It is your fault!")

  robot.hear /goto (.*) (.*)/i, (msg) ->
    add_user_on_location(msg)

search_for_venue = (callback) ->
  options =
    host:'api.foursquare.com'
    path: "/v2/venues/search?ll=#{location}&client_id=#{client_id}&client_secret=#{client_secret}&categoryId=#{category_food}&radius=1000&v=20120701&intent=browse"
    method: 'GET'
  result = ""
  request = https.get(options)
  request.on 'response', (res) ->
    res.on 'data', (data) ->
      result += data
    res.on 'end', ->
      venues = JSON.parse(result)['response']['venues']
      callback(pick_venue venues)

pick_venue = (venues) ->
  random_number = Math.floor(Math.random() * venues.length)
  chosen_venue = venues[random_number]
