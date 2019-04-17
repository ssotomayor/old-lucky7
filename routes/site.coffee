JsonRenderer           = require "../lib/json_renderer"
_                      = require "underscore"
_str                   = require "../lib/underscore_string"
querystring            = require "querystring"

module.exports = (app)->

  render = (res, tpl, titlePrefix, description = null, playGame = null, gameData = null)->
    res.render "site/#{tpl}",
      title: "#{titlePrefix} - Satoshibet"
      description: description
      playGame: playGame
      gameData: gameData
      jackpotMinCap: 1
      _str: _str

  app.get "/", (req, res)->
    res.redirect "/lucky7"

  app.get "/lucky7", (req, res)->
    slug = req.query.player
    title = res.__ "Bitcoin Slot Machine Lucky 7"
    description = res.__ "Bitcoin Slot Machine. Play 3-reel slot machine Lucky 7 and win the Progressive Jackpot. No registration. Provably Fair."
    playGame = "lucky7"
    req.session.playGame = playGame
    render res, "casino_game", title, description, playGame

  app.get "/player.json/:uid?", (req, res)->
    playerJson =
      type: "free"
      username: "test"
      email: "test"
      address: "test"
      balance: "free"
      slug: ""
      selected_balance_type: "free"
      id: "123"
    res.json playerJson
