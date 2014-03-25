# Meet Ada

This is a version of GitHub's kegerator-powered life embetterment robot, hubot, that we use internally at [Rendered Text](https://github.com/renderedtext).

Ada is geek and she lives on [Heroku](https://heroku.com).

She loves to chat on our [Slack](https://slack.com/) chatroom, poke us while we're working, and that stuff, you know women (joke :smiley:).

**TL;DR** She's pretty cool.

## Environment variables

To run this version of hubot + scripts that we use, you will need to set some environment variables.

    === rt-hubot Config Vars
    HEROKU_URL

    FOURSQUARE_CLIENT_ID
    FOURSQUARE_CLIENT_SECRET

    HUBOT_SLACK_TOKEN
    HUBOT_SLACK_TEAM
    HUBOT_SLACK_BOTNAME

    REDISTOGO_URL
    HUBOT_SEMAPHOREAPP_AUTH_TOKEN
    HUBOT_SEMAPHOREAPP_TRIGGER


## Testing Hubot Locally

You can test your hubot by running the following.

    % bin/hubot

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `hubot help`.

    Hubot> hubot help

    Hubot> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...

Take a look at the scripts in the `./scripts` folder for examples.
Delete any scripts you think are silly.  Add whatever functionality you
want hubot to have.

## hubot-scripts

There will inevitably be functionality that everyone will want. Instead
of adding it to hubot itself, you can submit pull requests to
[hubot-scripts][hubot-scripts].

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the `hubot-scripts.json` file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

### Deployment

If you would like to deploy to either a UNIX operating system or Windows.
Please check out the [deploying hubot onto UNIX][deploy-unix] and
[deploying hubot onto Windows][deploy-windows] wiki pages.

[heroku-node-docs]: http://devcenter.heroku.com/articles/node-js
[deploy-heroku]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-Heroku
[deploy-unix]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-UNIX
[deploy-windows]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-Windows

## Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart`
if you're having issues.

