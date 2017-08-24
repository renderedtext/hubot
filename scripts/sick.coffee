module.exports = (robot) ->
  robot.respond /ropsii/i, (msg) ->
    msg.http("http://a.4cdn.org/b/catalog.json")
      .get() (err, res, body) ->
        tim = JSON.stringify(JSON.parse(body)[5]["threads"][5]["tim"])
        ext = JSON.stringify(JSON.parse(body)[5]["threads"][5]["ext"]).replace /"/, ""
        parsed_ext = ext.replace /"/, ""
        msg.send "http://i.4cdn.org/b/#{tim}#{parsed_ext}"
