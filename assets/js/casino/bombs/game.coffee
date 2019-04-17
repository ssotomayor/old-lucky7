window.Bombs or= {}

class window.Bombs.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new Bombs.View options
    @player = options.player
    $.subscribe "play", @playGame
    $.subscribe "step", @step
    $.subscribe "cashout", @cashout
    $.subscribe "re-shuffle", @reShuffle
    @start()

  start: ()=>
    @view.renderGameTable()
    cols = @view.getColumnsNumber()
    rows = @view.getRowsNumber()
    @shuffle null, cols, rows

  reShuffle: (ev, cols, rows)=>
    @shuffle ev, cols, rows, (response)=>
      if response.game_state
        @view.renderFields(response.game_state)
      else
        @view.renderFields(response)

  shuffle: (ev, cols, rows, callback)=>
    @view.showBetChoices("start-game")
    @model.action "shuffle",
      data:
        cols: cols
        rows: rows
      success: (response)=>
        if response.game_state
          if !response.game_state.started 
            @view.showBetChoices("start-game")
          else
            @view.showBetChoices("take-profit")
          @view.renderFields response.game_state
          @player.reactOnBalanceChange = true
        else
          @view.showBetChoices("start-game")
          $.publish "hash-secret", response.hash_secret
          $.publish "client-seed", @model.generateClientSeed()
        callback(response) if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  playGame: (ev, cols, rows, wager, clientSeed)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @view.showBetChoices("take-profit")
    @model.action "play",
      data:
        cols: cols
        rows: rows
        wager: wager
        client_seed: clientSeed
      success: (response)=>
          @player.setBalance response.balance
          @player.reactOnBalanceChange = true
          @view.renderFields(response)
          @view.showBetChoices("take-profit")
      error: (xhr)=>
        @view.showBetChoices("start-game")
        $.publish "error", xhr

  step: (ev, tile)=>
    @player.reactOnBalanceChange = false
    @model.action "step",
      data:
        tile: tile
      success: (response)=>
        queue = {}
        queue.game_result = ()=>
          $.publish "step-result", response
          App.Helpers.Sound.play (if response.result is "lose" then "bomb" else "step")
          if ["lose", "win"].indexOf(response.result) > -1
            @view.showBetChoices("start-game")
            @player.setBalance response.balance
            @player.reactOnBalanceChange = true
            @view.renderFields(response)  if response.result is "lose"
            cols = @view.getColumnsNumber()
            rows = @view.getRowsNumber()
            @shuffle null, cols, rows, ()=>
              $.publish "game-result", response
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  cashout: (ev)=>
    @player.reactOnBalanceChange = false
    @view.showBetChoices("start-game")
    @model.action "cashout",
      success: (response)=>
        queue = {}
        queue.game_result = ()=>
          @player.setBalance response.balance
          @player.reactOnBalanceChange = true
          @view.renderFields(response)
          cols = @view.getColumnsNumber()
          rows = @view.getRowsNumber()
          @shuffle null, cols, rows, ()=>
            $.publish "game-result", response
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices("take-profit")
        $.publish "error", xhr
        @player.reactOnBalanceChange = true
