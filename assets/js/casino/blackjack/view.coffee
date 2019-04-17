window.Blackjack or= {}

class window.Blackjack.View extends App.MasterView

  el: null

  tpl: null

  sounds: {}

  events:
    "click #bet-bt": "onBetClick"
    "click #stand-bt": "onStandClick"
    "click #split-bt": "onSplitClick"
    "click #hit-bt": "onHitClick"
    "click #double-bt": "onDoubleClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"

  initialize: ({@tpl, @provablyFair})->
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @showBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "deal"

  renderDealerCard: (card = {})->
    $dealerCards = @$("#dealer-cards")
    @renderCard card, $dealerCards  if not @replaceFlippedCard card, $dealerCards

  renderPlayerCard: (card = {}, hand = 1)->
    @renderCard card, @$("#player-cards-#{hand}")

  renderCard: (card = {}, $el)->
    @tpl = "blackjack-card-tpl"
    $el.append @template({card: card})
    App.Helpers.Sound.play "deal"  if not card.noanim

  renderGameResult: (gameResult)->
    @tpl = "blackjack-game-result-tpl"
    index = 1
    for handResult in gameResult.result
      @$("#game-result-cnt").append @template({gameResult: handResult})
      index++

  renderFlippedCard: ()->
    @renderCard {flipped: true}, @$("#dealer-cards")

  replaceFlippedCard: (card, $cnt)->
    $flippedCard = $cnt.find ".flipped"
    if $flippedCard.length
      $flippedCard.remove()
      card.turn = true
      @renderCard card, $cnt
      return true
    false

  renderDealerScore: (score)->
    score = score.join()  if _.isArray score
    @$("#dealer-score").text score

  renderPlayerScore: (score, hand = 1)->
    score = score.join()  if _.isArray score
    @$("#player-score-#{hand}").text score

  renderPlayerHandIndicator: (hand = null)->
    @$(".card-arrow").hide()
    @$("#player-arrow-#{hand}").show()  if hand

  clearDealerCards: ()->
    @$("#dealer-cards").empty()

  clearPlayerCards: ()->
    @$("#player-cards-1,#player-cards-2,#player-cards-3,#player-cards-4")
    .empty()

  clearScores: ()->
    @$("#dealer-score,#player-score-1,#player-score-2,#player-score-3,#player-score-4")
    .empty()

  hideBetChoices: ()->
    @$("#bet-choices .action, #bet-choices input")
    .addClass("disabled")
    .attr
      disabled: "disabled"

  showBetChoices: (allowedActions = null)->
    if allowedActions
      @lastAllowedActions = allowedActions
    else
      allowedActions = @lastAllowedActions
    if allowedActions
      @$("#bet-choices input")
      .removeClass("disabled")
      .removeAttr("disabled")
      for bt in @$("#bet-choices .action")
        $bt = $(bt)
        if allowedActions.indexOf($bt.data("action")) > -1
          $bt.removeClass("disabled").removeAttr("disabled")
        else
          $bt.addClass("disabled").attr({disabled: "disabled"})
      @$("#bet-choices .operators .action")
      .removeClass("disabled")
      .removeAttr("disabled")

  getWager: ()->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree $amount.val()
    $amount.val wager
    wager

  setBetAmount: (wager)->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree wager
    $amount.val wager

  cleanTable: ()->
    @clearDealerCards()
    @clearPlayerCards()
    @clearScores()
    @$("#game-result-cnt").empty()
    @$(".card-arrow").hide()

  bet: ()->
    @cleanTable()
    clientSeed = @provablyFair.getClientSeed()
    $.publish "bet", [@getWager(), clientSeed]

  stand: ()->
    $.publish "stand"

  split: ()->
    $.publish "split", @getWager()

  hit: ()->
    $.publish "hit"

  double: ()->
    $.publish "double", @getWager()

  multiplyBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() * 2)

  divideBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() / 2)

  onBetClick: (ev)=>
    ev.preventDefault()
    @bet()

  onStandClick: (ev)=>
    ev.preventDefault()
    @stand()

  onSplitClick: (ev)=>
    ev.preventDefault()
    @split()

  onHitClick: (ev)=>
    ev.preventDefault()
    @hit()

  onDoubleClick: (ev)=>
    ev.preventDefault()
    @double()

  onBetMultiplierClick: (ev)=>
    ev.preventDefault()
    @multiplyBet()
    
  onBetDividerClick: (ev)=>
    ev.preventDefault()
    @divideBet()

  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        #enter
        when 13
          if @$("#bet-bt").is(":enabled") then @bet()
          if @$("#hit-bt").is(":enabled") then @hit()
        #right key
        when 39 then @multiplyBet() if @$("#bet-amount").is(":enabled")
        #left key
        when 37 then @divideBet() if @$("#bet-amount").is(":enabled")
        #space key
        when 32 then @stand() if @$("#stand-bt").is(":enabled")
        #d key
        when 68 then @double() if @$("#double-bt").is(":enabled")
        #s key
        when 83 then @split() if @$("#split-bt").is(":enabled")

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]

  onGameResult: (ev, result)=>
    @renderGameResult result
