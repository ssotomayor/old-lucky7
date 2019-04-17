window.CasinoWar or= {}

class window.CasinoWar.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new CasinoWar.View options
    @player = options.player
    $.subscribe "bet", @bet
    $.subscribe "surrender", @surrender
    $.subscribe "go-to-war", @goToWar
    @start()

  start: ()=>
    @view.renderGameTable()
    @shuffle()

  shuffle: (callback)=>
    @model.action "shuffle",
      success: (response)=>
        if response.game_state and response.game_state.result is "tie"
          @restoreFromResponse response
          @player.reactOnBalanceChange = true
        else
          @view.showBetChoices()
          $.publish "hash-secret", response.hash_secret
          $.publish "client-seed", @model.generateClientSeed()
        callback() if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  bet: (ev, wager, clientSeed, betOnTie)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager, betOnTie
    @player.setBalance @player.get("balance") - wager, false
    @player.setBalance @player.get("balance") - wager, false if betOnTie
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "bet",
      data:
        wager: wager
        client_seed: clientSeed
        bet_on_tie: betOnTie
      success: (response)=>
        App.Helpers.Queue.execute
          dealer_card: ()=>
            @view.renderDealerCard response.dealer_card
          player_card: ()=>
            @view.renderPlayerCard response.player_card
          game_result: ()=>
            if response.result is "tie"
              @view.showTieChoices response.war_tax, response.surrender_tax
              @player.reactOnBalanceChange = true
            else
              @shuffle ()=>
                $.publish "game-result", response
                @player.setBalance response.balance
                @player.reactOnBalanceChange = true
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  surrender: ()=>
    @player.reactOnBalanceChange = false
    @model.action "tie_bet",
      data:
        choice: "surrender"
      success: (response)=>
        @shuffle ()=>
          @view.hideTieChoices()
          $.publish "game-result", response
          @player.setBalance response.balance
          @player.reactOnBalanceChange = true
      error: (xhr)=>
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  goToWar: (ev, wager)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @view.hideTieChoices()
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @model.action "tie_bet",
      data:
        choice: "war"
      success: (response)=>
        App.Helpers.Queue.execute
          burned_card_1: ()=>
            @view.renderBurnedCard()
          burned_card_2: ()=>
            @view.renderBurnedCard()
          burned_card_3: ()=>
            @view.renderBurnedCard()
          dealer_card: ()=>
            @view.renderDealerCard response.dealer_card
          player_card: ()=>
            @view.renderPlayerCard response.player_card
          game_result: ()=>
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
      error: (xhr)=>
        @view.showTieChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  restoreFromResponse: (response)->
    @view.renderDealerCard response.game_state.dealer_card
    @view.renderPlayerCard response.game_state.player_card
    @view.hideBetChoices()
    @view.showTieChoices response.game_state.war_tax, response.game_state.surrender_tax
    @view.setBetAmount response.game_state.wager
