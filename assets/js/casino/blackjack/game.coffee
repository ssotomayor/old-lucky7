window.Blackjack or= {}

class window.Blackjack.Game

  model: null

  view: null

  player: null

  constructor: (options)->
    @model = new App.GameModel options
    @view = new Blackjack.View options
    @player = options.player
    $.subscribe "bet", @bet
    $.subscribe "stand", @stand
    $.subscribe "split", @split
    $.subscribe "hit", @hit
    $.subscribe "double", @double
    @start()

  start: ()=>
    @view.renderGameTable()
    @shuffle()

  shuffle: (callback)=>
    @model.action "shuffle",
      success: (response)=>
        if response.game_state
          @restoreFromResponse response
          @player.reactOnBalanceChange = true
        else
          @view.showBetChoices response.allowed_actions
          $.publish "hash-secret", response.hash_secret
          $.publish "client-seed", @model.generateClientSeed()
        callback() if _.isFunction callback
      error: (xhr)=>
        $.publish "error", xhr
        callback() if _.isFunction callback

  bet: (ev, wager, clientSeed)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "bet",
      data:
        wager: wager
        client_seed: clientSeed
      success: (response)=>
        App.Helpers.Queue.execute
          dealer_card: ()=>
            @view.renderDealerCard response.dealer_cards[0]
          player_card: ()=>
            @view.renderPlayerCard response.player_hands[0].cards[0]
          dealer_card_2: ()=>
            if response.dealer_cards[1]
              @view.renderDealerCard response.dealer_cards[1]
            else
              @view.renderFlippedCard()
          player_card_2: ()=>
            @view.renderPlayerCard response.player_hands[0].cards[1]
          scores: ()=>
            @view.renderDealerScore response.dealer_score
            @view.renderPlayerScore response.player_hands[0].score
            @view.renderPlayerHandIndicator response.player_hand_id + 1  if response.player_hands.length > 1
          game_result: ()=>
            @view.showBetChoices response.allowed_actions
            @player.setBalance response.balance
            @player.reactOnBalanceChange = true
            if response.result
              @shuffle ()=>
                $.publish "game-result", response
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  stand: (ev)=>
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "stand",
      success: (response)=>
        queue = {}
        if response.dealer_cards
          addCardToQueue = (card, i)=>
            queue["dealer_card_#{i}"] = ()=>
              @view.renderDealerCard card
          index = 0
          for dealerCard in response.dealer_cards
            index++
            addCardToQueue dealerCard, index
        queue.scores = ()=>
          @view.renderDealerScore response.dealer_score
          @view.renderPlayerHandIndicator response.player_hand_id + 1  if response.player_hands.length > 1
        if response.result
          queue.game_result = ()=>
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
        else
          # TODO: move current hand arrow
          @view.showBetChoices response.allowed_actions
          @player.reactOnBalanceChange = true
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  split: (ev, wager)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "split",
      success: (response)=>
        @view.clearPlayerCards()
        addCardToQueue = (card, hI, i)=>
          queue["player_card_#{hI}_#{i}"] = ()=>
            @view.renderPlayerCard card, hI
        addHandToQueue = (hand, hI)=>
          index = 0
          for playerCard in hand.cards
            index++
            addCardToQueue playerCard, hI, index  if index > 1
            @view.renderPlayerScore hand.score, handIndex  if index > 1
        addHandFirstCardToQueue = (hand, hI)=>
          hand.cards[0].noanim = true
          @view.renderPlayerCard hand.cards[0], hI
        queue = {}
        handIndex = 0
        for hand in response.player_hands
          handIndex++
          addHandFirstCardToQueue hand, handIndex
        handIndex = 0
        for hand in response.player_hands
          handIndex++
          addHandToQueue hand, handIndex
        queue.hand_indicator = ()=>
          @view.renderPlayerHandIndicator response.player_hand_id + 1  if response.player_hands.length > 1
        App.Helpers.Queue.execute queue
        @view.showBetChoices response.allowed_actions
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  hit: (ev)=>
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "hit",
      success: (response)=>
        queue = {}
        queue.player_card = ()=>
          @view.renderPlayerCard response.player_card, response.player_card_hand_id + 1
          @view.renderPlayerScore response.player_hands[response.player_card_hand_id].score, response.player_card_hand_id + 1
        if response.dealer_cards
          addCardToQueue = (card, i)=>
            queue["dealer_card_#{i}"] = ()=>
              @view.renderDealerCard card
          index = 0
          for dealerCard in response.dealer_cards
            index++
            addCardToQueue dealerCard, index
        queue.scores = ()=>
          @view.renderDealerScore response.dealer_score
        queue.game_result = ()=>
          @view.showBetChoices response.allowed_actions
          @view.renderPlayerHandIndicator response.player_hand_id + 1  if response.player_hands.length > 1
          if response.result
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  double: (ev, wager)=>
    return $.publish "error", @player.getLastError() if not @player.isValidBet wager
    @player.setBalance @player.get("balance") - wager, false
    @player.reactOnBalanceChange = false
    @view.hideBetChoices()
    @model.action "double",
      success: (response)=>
        queue = {}
        queue.player_card = ()=>
          @view.renderPlayerCard response.player_card, response.player_card_hand_id + 1
          @view.renderPlayerScore response.player_hands[response.player_card_hand_id].score, response.player_card_hand_id + 1
          @view.renderPlayerHandIndicator response.player_hand_id + 1  if response.player_hands.length > 1
        addCardToQueue = (card, i)=>
          queue["dealer_card_#{i}"] = ()=>
            @view.renderDealerCard card
        if response.dealer_cards
          index = 0
          for dealerCard in response.dealer_cards
            index++
            addCardToQueue dealerCard, index
        queue.scores = ()=>
          @view.renderDealerScore response.dealer_score
        queue.game_result = ()=>
          @view.showBetChoices response.allowed_actions
          if response.result
            @shuffle ()=>
              $.publish "game-result", response
              @player.setBalance response.balance
              @player.reactOnBalanceChange = true
        App.Helpers.Queue.execute queue
      error: (xhr)=>
        @view.showBetChoices()
        $.publish "error", xhr
        @player.reactOnBalanceChange = true

  restoreFromResponse: (response)->
    index = 0
    for dealerCard in response.game_state.dealer_cards
      index++
      @view.renderDealerCard dealerCard
    @view.renderFlippedCard() if response.game_state.dealer_cards.length is 1
    handIndex = 1
    for playerHand in response.game_state.player_hands
      cardIndex = 0
      for playerCard in playerHand.cards
        @view.renderPlayerCard playerCard, handIndex
        cardIndex++
      @view.renderPlayerScore playerHand.score, handIndex
      handIndex++
    @view.renderPlayerHandIndicator response.game_state.player_hand_id + 1  if response.game_state.player_hands.length > 1
    @view.showBetChoices response.allowed_actions
    @view.setBetAmount response.game_state.wager

