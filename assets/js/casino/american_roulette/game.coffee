window.AmericanRoulette or= {}

class window.AmericanRoulette.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new AmericanRoulette.View options
    @player = options.player
    $.subscribe "spin", @spin
    @start()

  start: ()=>
    @view.renderGameTable()
    @view.restoreTableState()
    @shuffle()

  shuffle: (callback)=>
    @model.action "shuffle",
      success: (response)=>
        @view.showBetChoices() if @view.getLastSelectedBet().length
        $.publish "hash-secret", response.hash_secret
        $.publish "client-seed", @model.generateClientSeed()
        callback() if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  spin: (ev, wagers, clientSeed)=>
    totalWager = 0
    for wagerType, wagerAmount of wagers
      totalWager += wagerAmount
    return $.publish "error", @player.getLastError() if not @player.isValidBet totalWager
    @player.setBalance @player.get("balance") - totalWager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "spin",
      data:
        wagers: wagers
        client_seed: clientSeed
      success: (response)=>
        App.Helpers.Queue.execute
          spinRoulette: ()=>
            @view.spinTheWheel response
          game_result: ()=>
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true
