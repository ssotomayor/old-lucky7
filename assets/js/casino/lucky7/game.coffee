window.Lucky7 or= {}

class window.Lucky7.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new Lucky7.View options
    @player = options.player
    $.subscribe "spin", @spin
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

  spin: (ev, wager, clientSeed)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "spin",
      data:
        wager: wager
        client_seed: clientSeed
      success: (response)=>
        App.Helpers.Queue.execute
          spin: ()=>
            @view.spinReels response
          game_result: ()=>
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true
