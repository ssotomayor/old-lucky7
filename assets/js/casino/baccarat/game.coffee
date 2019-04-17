window.Baccarat or= {}

class window.Baccarat.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new Baccarat.View options
    @player = options.player
    $.subscribe "deal", @deal
    @start()

  start: ()=>
    @view.renderGameTable()
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

  deal: (ev, wagers, clientSeed)=>
    totalWager = 0
    for wagerType, wagerAmount of wagers
      totalWager += wagerAmount
    return $.publish "error", @player.getLastError() if not @player.isValidBet totalWager
    @player.setBalance @player.get("balance") - totalWager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "deal",
      data:
        wagers: wagers
        client_seed: clientSeed
      success: (response)=>
        queue = {}
        addCardToQueue = (card, type, index)=>
          if card?
            queue["bc_#{type}_card_#{index}"] = ()=>
              @view.renderPlayerCard card  if type is "player"
              @view.renderBankerCard card  if type is "banker"
        addScoreToQueue = (score, type, index)=>
          if score?
            queue["bc_#{type}_score_#{index}"] = ()=>
              @view.renderPlayerScore score  if type is "player"
              @view.renderBankerScore score  if type is "banker"
        for index in [0..2]
          addCardToQueue response.player_cards[index], "player", index + 1
          addScoreToQueue response.player_scores[index], "player", index + 1
          addCardToQueue response.banker_cards[index], "banker", index + 1
          addScoreToQueue response.banker_scores[index], "banker", index + 1
        queue.game_result = ()=>
          @view.showBetChoices()
          @shuffle ()=>
            $.publish "game-result", response
            @player.setBalance response.balance
            @player.reactOnBalanceChange = true
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true
