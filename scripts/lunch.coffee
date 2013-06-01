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

client_id = 'ORUE1VLPYRFYCAIZRMOHYYZESVYCEKU1I1BAIOSCIEJMRRRO'
client_secret = 'NPXT4T1Z0NUUJNBF5NKGDYBUI3WVICVDY4H4JLRUIBK4WMY4'

category_food = '4d4b7105d754a06374d81259'
category_drink = '4d4b7105d754a06376d81259'

location= '45.257217,19.845845'

https = require 'https'

module.exports = (robot) ->
  robot.respond /lunch/i, (msg) ->
    search_for_venue (venue) ->
      venue.url = "https://foursquare.com/v/#{venue.id}"
      msg.send "We're having lunch at #{venue.name}: #{venue.url}"

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
