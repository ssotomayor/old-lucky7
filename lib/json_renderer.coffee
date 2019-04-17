SlotMachine      = require "./casino/slot_machine"
AppHelper        = require "./app_helper"
_                = require "underscore"
_str             = require "./underscore_string"

JsonRenderer =

  gameResponse: (game, response)->
    # convert response properties
    keysToConvert = [
      "amount", "balance", "won_amount", "lost_amount",
      "charged_amount", "charged_tie_amount", "tie_bet",
      "surrender_tax", "war_tax",
      "profit", "wager"
    ]
    for key in keysToConvert
      response[key] = AppHelper.renderFloatBalance(response[key], game.getCurrency())  if response[key]?

    gameStateKeys = [
      "wager", "war_tax", "surrender_tax", "tie_bet", "charged_tie_amount",
      "charged_amount"
    ]
    if response.game_state
      for key in gameStateKeys
        response.game_state[key] = AppHelper.renderFloatBalance(response.game_state[key], game.getCurrency())  if response.game_state[key]?
    
    response

  player: (player, options = {withId: true})->
    playerJson =
      type: player.type
      username: player.username
      email: player.email
      address: player.getAddress()
      balance: AppHelper.renderFloatBalance player.getBalance(), player.getBalanceType()
      slug: player.slug
      selected_balance_type: player.getBalanceType()
    playerJson.id = player.uid if options.withId
    playerJson

  error: (err, res, code = 409, log = false)->
    res.statusCode = code
    message = ""
    if _.isString err
      message = err
    else if _.isObject(err) and err.name is "ValidationError"
      for key, val of err.errors
        if val.path is "email" and val.message is "unique"
          message += "E-mail is already taken. "
        else
          message += "#{val.message} "
    message = res.__ message  if res.__
    res.json {error: message}
    console.error message  if log

  sqlError: (err, res, code = 409, log = true)->
    console.error err  if log
    res.statusCode = code  if res
    if _.isObject(err)
      delete err.sql
      return res.json {error: @formatError("#{err}")}  if res and err.code is "ER_DUP_ENTRY"
    message = ""
    if _.isString err
      message = err
    else if _.isObject(err)
      for key, val of err
        if _.isArray val
          message += "#{val.join(' ')} "
        else
          message += "#{val} "
    return res.json {error: @formatError(message)}  if res
    @formatError(message)

  formatError: (message)->
    message = message.replace "Error: ER_DUP_ENTRY: ", ""
    message = message.replace /for key.*$/, ""
    message = message.replace /Duplicate entry/, "Value already taken"
    message = message.replace "ConflictError ", ""
    _str.trim message

exports = module.exports = JsonRenderer