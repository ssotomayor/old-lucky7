window.VideoPoker or= {}

class window.VideoPoker.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new VideoPoker.View options
    @player = options.player
    $.subscribe "bet", @bet
    $.subscribe "draw", @draw
    $.subscribe "re-shuffle", @reShuffle
    @start()

  start: ()=>
    @view.renderGameTable()
    paytable = @view.getPaytable()
    @shuffle paytable

  reShuffle: (ev, paytable)=>
    @shuffle paytable, (response)=>
      @view.clearPlayerCards()
      if response.game_state
        @restoreFromResponse response
      else
        @view.renderPayoutTable response
  
  shuffle: (paytable, callback)=>
    @model.action "shuffle",
      data:
        paytable: paytable
      success: (response)=>
        if response.game_state
          @restoreFromResponse response
          @player.reactOnBalanceChange = true
        else
          @view.showBetChoices response.allowed_actions
          #@view.renderPayoutTable response
          $.publish "hash-secret", response.hash_secret
          $.publish "client-seed", @model.generateClientSeed()
        callback(response) if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  bet: (ev, wager, clientSeed)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @view.clearPlayerScore()
    @model.action "bet",
      data:
        wager: wager
        client_seed: clientSeed
      success: (response)=>
        queue = {}
        addCardToQueue = (card, index)=>
          queue["vp_player_card_#{index}"] = ()=>
            @view.replacePlayerCard card, index
        index = 0
        for playerCard in response.player_cards
          index++
          addCardToQueue playerCard, index
        queue.vp_score = ()=>
          @view.renderPlayerScore response
          @view.showBetChoices response.allowed_actions
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  draw: (ev, heldCards)=>
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "draw",
      data:
        cards_to_hold: heldCards
      success: (response)=>
        @player.setBalance @player.get("balance"), false
        @player.reactOnBalanceChange = false
        queue = {}
        addCardToQueue = (card, index, hold)=>
          if not hold
            queue["vp_player_card_#{index}"] = ()=>
              card.turn = true
              @view.replacePlayerCard card, index
        index = 0
        for playerCard in response.player_cards
          index++
          hold = response.hold_cards.indexOf("#{index - 1}") > -1
          addCardToQueue playerCard, index, hold
        @view.clearHoldCards()
        queue.vp_score = ()=>
          @view.renderPlayerScore response
        queue.vp_game_result = ()=>
          paytable = @view.getPaytable()
          @shuffle paytable, ()=>
            $.publish "game-result", response
            @player.setBalance response.balance
            @player.reactOnBalanceChange = true
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  restoreFromResponse: (response)->
    @view.clearPlayerCards()  if response.game_state.player_cards.length
    index = 0
    for playerCard in response.game_state.player_cards
      index++
      @view.replacePlayerCard playerCard, index
    @view.renderPayoutTable response.game_state
    @view.setWager response.game_state.wager
    @view.setPaytable response.game_state.paytable
    @view.showBetChoices response.allowed_actions