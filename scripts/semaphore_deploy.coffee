# Description
#   Uses Semaphore's API to start deployments.
#
# Configuration:
#   HUBOT_SEMAPHOREAPP_AUTH_TOKEN
#     Your authentication token for Semaphore API
#
# Commands
#   hubot deploy project/branch to server - deploys project/branch to server
#   hubot deploy project to server - deploys project/master to server

module.exports = (robot) ->

  robot.respond /deploy (.*)$/i, (msg) =>
    unless process.env.HUBOT_SEMAPHOREAPP_AUTH_TOKEN
      return msg.reply "I need HUBOT_SEMAPHOREAPP_AUTH_TOKEN for this to work."

    command       = msg.match[1]
    parsedCommand = parseCommand(command)

    if parsedCommand?
      [projectName, branchName, serverName] = parsedCommand
      deploy(msg, projectName, branchName, serverName)
    else
      msg.reply "I don't understand what you want from me. I refuse to deploy."

#
# Parses the message that hubot recieved
# return [project, branch, server] if succeds
# otherwise null
#
parseCommand = (command) ->
  projectBranchServer = command.match /(\w*)\/(.*)\s+to\s+(.*)/ # project/branch to server
  projectBranch       = command.match /(.*)\s+to\s+(.*)/       # project to server

  switch
    when projectBranchServer? then projectBranchServer[1..3]
    when projectBranch? then [projectBranch[1], 'master', projectBranch[2]]
    else null

#
# Performs deployment using semaphore
#
deploy = (msg, projectName, branchName, serverName) ->
  console.log projectName, branchName, serverName
  app = new SemaphoreApp(msg)

  app.getProjects (projects) ->
    [project_obj] = (project for project in projects when project.name == projectName)

    return msg.reply "Can't find project #{projectName}" unless project_obj

    [branch_obj] = (b for b in project_obj.branches when b.branch_name == branchName)

    return msg.reply "Can't find branch #{projectName}/#{branchName}" unless branch_obj
    return msg.reply "#{projectName}/#{branchName} – last build is #{branch_obj.result}. Aborting deploy." unless branch_obj.result == 'passed'

    [server_obj] = (server for server in project_obj.servers when server.server_name == serverName)

    return msg.reply "Can't find server #{serverName} for project #{projectName}" unless server_obj

    app.getBranches project_obj.hash_id, (branches) ->
      app.getServers project_obj.hash_id, (servers) ->
        [branch_id] = (b.id for b in branches when b.name == branchName)
        [server_id] = (s.id for s in servers when s.name == serverName)

        app.createDeploy project_obj.hash_id, branch_id, branch_obj.build_number, server_id, (json) ->
          msg.send "Deploying #{projectName}/#{branchName} to #{serverName} ( #{json.html_url} )"

class SemaphoreApp
  constructor: (@msg) ->

  requester: (endpoint) ->
    @msg.robot
        .http("https://semaphoreapp.com/api/v1/#{endpoint}")
        .query(auth_token: "#{process.env.HUBOT_SEMAPHOREAPP_AUTH_TOKEN}")

  get: (endpoint, callback) ->
    # console.log "GET #{endpoint}"
    @requester(endpoint).get() (err, res, body) =>
      @msg.reply "Semaphore connection error: #{err}" unless err == null

      try
        json = JSON.parse body
        callback json
      catch error
        @msg.reply "Semaphore error: #{error} #{body}"

  post: (endpoint, callback) ->
    # console.log "POST #{endpoint}"
    data = JSON.stringify {}

    @requester(endpoint).post(data) (err, res, body) =>
      try
        json = JSON.parse body
        callback json
      catch error
        @msg.reply "Semaphore error: #{error} / #{res} / #{body}"

  getProjects: (callback) ->
    @get 'projects', callback

  getBranches: (project, callback) ->
    @get "projects/#{project}/branches", callback

  getServers: (project, callback) ->
    @get "projects/#{project}/servers", callback

  createDeploy: (project, branch, build, server, callback) ->
    @post "projects/#{project}/#{branch}/builds/#{build}/deploy/#{server}", callback
