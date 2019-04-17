window.Dice or= {}

class window.Dice.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new Dice.View options
    @player = options.player
    $.subscribe "roll", @roll
    $.subscribe "balance-updated", @updateBalance
    @start()

  start: ()=>
    @view.renderGameTable()
    @shuffle()

  shuffle: (callback)=>
    @model.action "shuffle",
      success: (response)=>
        @view.showBetChoices()
        $.publish "hash-secret", response.hash_secret
        $.publish "client-seed", @model.generateClientSeed()
        callback() if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  roll: (ev, wager, clientSeed)=>
    errorMessages = App.Helpers.Casino.Dice.getValidationErrors(wager)
    for errorText in errorMessages
      return $.publish "error", errorText
    return $.publish "error", @player.getLastError() if not @player.isValidBetNoMaxCap wager.amount
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @view.clearDiceColor()
    @model.action "roll",
      data:
        wager: wager
        client_seed: clientSeed
      success: (response)=>
        App.Helpers.Sound.play "roll"
        queue = {}
        queue.game_result = ()=>
          @shuffle ()=>
            $.publish "game-result", response
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  updateBalance: (ev, balance)=>
    @player.setBalance balance
    @player.reactOnBalanceChange = true
