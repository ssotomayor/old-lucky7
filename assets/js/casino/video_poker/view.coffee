window.VideoPoker or= {}

class window.VideoPoker.View extends App.MasterView

  el: null

  tpl: null

  sounds: {}

  events:
    "click #bet-bt": "onBetClick"
    "click #draw-bt": "onDrawClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"
    "click .card": "onCardClick"
    "change #pay-table-dropdown": "onPaytableChange"

  initialize: ({@tpl, @provablyFair})->
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @showBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "deal"

  renderPlayerCard: (card, index)->
    card.id = "player-card-#{index}"
    card.index = index - 1
    @renderCard card, @$("#player-cards")

  replacePlayerCard: (card, index)->
    card.id = "player-card-#{index}"
    card.index = index - 1
    @renderCard card, @$("#player-card-#{index}"), "replaceWith"

  renderCard: (card = {}, $el, action = "append")->
    @tpl = "video-poker-card-tpl"
    $el[action] @template({card: card})
    App.Helpers.Sound.play "deal"  if action is "replaceWith"

  renderGameResult: (gameResult)->
    @tpl = "video-poker-game-result-tpl"
    @$("#game-result-cnt").html @template({gameResult: gameResult})

  renderPayoutTable: (gameResult)->
    @$("#game-result-cnt").empty()
    @setPaytable gameResult.paytable
    @tpl = "video-poker-payout-table-tpl"
    @$("#pay-table").html @template({gameResult: gameResult})
    @renderPlayerScore gameResult

  renderPlayerScore: (gameResult)->
    @$("#pay-table .selected").removeClass("selected")
    id = gameResult.hand_id
    #name = gameResult.hand_name
    #multiplier = gameResult.hand_multiplier
    @$("##{id}").addClass("selected")  if id      

  clearPlayerScore: ()->
    @$("#pay-table .selected").removeClass("selected")
    @$("#game-result-cnt").empty()

  clearHoldCards: ()->
    @$("#player-cards .card.hold").removeClass "hold"

  clearPlayerCards: ()->
    @$("#player-cards .card").remove()
    flippedCard = {flipped: true}
    for id in [1..5]
      @renderPlayerCard flippedCard, id

  hideBetChoices: ()->
    @$("#bet-choices .pay-table-select, #bet-choices .action, #bet-choices input")
    .addClass("disabled")
    .attr
      disabled: "disabled"

  showBetChoices: (allowedActions = null)->
    if allowedActions
      @lastAllowedActions = allowedActions
    else
      allowedActions = @lastAllowedActions
    if allowedActions
      for bt in @$("#bet-choices .action")
        $bt = $(bt)
        if allowedActions.indexOf($bt.data("action")) > -1
          $bt.removeClass("disabled").removeAttr("disabled")
        else
          $bt.addClass("disabled").attr({disabled: "disabled"})

      if allowedActions[0] is "bet"
        @$("#bet-choices input, #bet-choices .pay-table-select, #bet-choices .operators .action")
        .removeClass("disabled")
        .removeAttr("disabled")
      if allowedActions[0] is "draw"
        @$("#bet-choices .pay-table-select")
        .addClass("disabled")
        .attr({disabled: "disabled"})
        
  getWager: ()->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree $amount.val()
    $amount.val wager
    wager

  setWager: (wager)->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree wager
    $amount.val wager

  getPaytable: ()->
    paytable = @$("#pay-table-dropdown").val()

  setPaytable: (paytable)->
    $paytable = @$("#pay-table-dropdown")
    $paytable.val paytable

  cleanTable: ()->
    @clearPlayerCards()
    @$("#game-result").empty()

  bet: ()->
    @cleanTable()
    clientSeed = @provablyFair.getClientSeed()
    wager = @getWager()
    paytable = @getPaytable()
    $.publish "bet", [wager, clientSeed]

  draw: ()->
    $.publish "draw", [@getHeldCards()]

  getHeldCards: ()->
    holdIds = []
    for card in @$(".card.hold")
      holdIds.push $(card).data("index")
    holdIds

  multiplyBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() * 2)

  divideBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() / 2)

  onCardClick: (ev)->
    @holdCard $(ev.currentTarget).data("index") + 1

  canHold: ()->
    @lastAllowedActions.indexOf("draw") > -1

  holdCard: (index)->
    $("#player-card-#{index}").toggleClass "hold"  if @canHold()

  onPaytableChange: (ev)=>
    ev.preventDefault()
    paytable = @getPaytable()
    $.publish "re-shuffle", [paytable]

  onBetClick: (ev)=>
    ev.preventDefault()
    @bet()

  onDrawClick: (ev)=>
    ev.preventDefault()
    @draw()

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
          if @$("#draw-bt").is(":enabled") then @draw()
        #right key
        when 39 then @multiplyBet() if @$("#bet-amount").is(":enabled")
        #left key
        when 37 then @divideBet() if @$("#bet-amount").is(":enabled")
        # 1 .. 5
        when 49 then @holdCard(1)
        when 50 then @holdCard(2)
        when 51 then @holdCard(3)
        when 52 then @holdCard(4)
        when 53 then @holdCard(5)

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]

  onGameResult: (ev, result)=>
    @renderGameResult result
