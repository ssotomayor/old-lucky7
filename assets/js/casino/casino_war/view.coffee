window.CasinoWar or= {}

class window.CasinoWar.View extends App.MasterView

  el: null

  tpl: null

  sounds: {}

  events:
    "click #surrender-bt": "onSurrenderClick"
    "click #go-to-war-bt": "onGoToWarClick"
    "click #bet-bt": "onBetClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"
    "keyup #bet-amount": "onBetAmountChange"

  initialize: ({@tpl, @provablyFair})->
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @hideTieChoices()
    @showBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "deal"

  renderDealerCard: (card = {})->
    @renderCard card, @$("#dealer-cards")

  renderPlayerCard: (card = {})->
    @renderCard card, @$("#player-cards")

  renderCard: (card = {}, $el)->
    @tpl = "casino-war-card-tpl"
    $el.append @template({card: card})
    App.Helpers.Sound.play "deal"

  renderGameResult: (gameResult)->
    @tpl = "casino-war-game-result-tpl"
    @$("#game-result-cnt").html @template({gameResult: gameResult})
    @markLostCard gameResult.result

  markLostCard: (result)->
    @$("#dealer-cards .card:last").addClass "lost" if result is "win"
    @$("#player-cards .card:last").addClass "lost" if result is "fail"

  renderBurnedCard: ()->
    @renderCard {flipped: true}, @$("#dealer-cards")

  hideTieChoices: ()->
    @$("#tie-choices").addClass("hidden")
    @$("#bet-choices").show()
    @$("#tie-choices .action")
    .addClass("disabled")
    .attr
      disabled: "disabled"

  showTieChoices: (warTax = 0, surrenderTax = 0)->
    $tieChoices = @$("#tie-choices")
    $tieChoices.removeClass("hidden")
    @$("#bet-choices").hide()
    $tieChoices.find(".action")
    .removeClass("disabled")
    .removeAttr("disabled")
    $tieChoices.find("#go-to-war-bt .tie-step-amount")
    .text(warTax)
    $tieChoices.find("#surrender-bt .tie-step-amount")
    .text(surrenderTax)

  hideBetChoices: ()->
    @$("#bet-choices .action, #bet-choices input")
    .addClass("disabled")
    .attr
      disabled: "disabled"

  showBetChoices: ()->
    @$("#bet-choices .action, #bet-choices input")
    .removeClass("disabled")
    .removeAttr("disabled")

  cleanTable: ()->
    @$("#dealer-cards").empty()
    @$("#player-cards").empty()
    @$("#game-result-cnt").empty()

  bet: ()->
    @cleanTable()
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree $amount.val()
    $amount.val wager
    clientSeed = @provablyFair.getClientSeed()
    $.publish "bet", [wager, clientSeed, @isBetOnTie()]

  setBetAmount: (wager)->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree wager
    $amount.val wager

  multiplyBet: ()->
    $amount = @$("#bet-amount")
    wager = parseFloat $amount.val()
    $amount.val _.str.roundToThree(wager * 2)

  divideBet: ()->
    $amount = @$("#bet-amount")
    wager = parseFloat $amount.val()
    $amount.val _.str.roundToThree(wager / 2)

  isBetOnTie: ()->
    @$("#bet-on-tie").is(":checked")

  toggleBetOnTie: ()->
    @$("#bet-on-tie").attr "checked", !@isBetOnTie()

  onBetClick: (ev)=>
    ev.preventDefault()
    @bet()

  onBetMultiplierClick: (ev)=>
    ev.preventDefault()
    @multiplyBet()
    
  onBetDividerClick: (ev)=>
    ev.preventDefault()
    @divideBet()

  onSurrenderClick: (ev)->
    $.publish "surrender"

  onGoToWarClick: (ev)=>
    $amount = @$("#bet-amount")
    wager = parseFloat $amount.val()
    $.publish "go-to-war", _.str.roundToThree(wager)

  onBetAmountChange: (ev)=>
    value = $(ev.target).val()
    amount = _.str.roundToThree value
    if value[value.length - 1] isnt "." and _.isNumber(amount) and amount <= CONFIG.maxCap and amount >= CONFIG.minCap
      $(ev.target).val amount

  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        #enter
        when 13 then @bet() if @$("#bet-bt").is(":enabled")
        #right key
        when 39 then @multiplyBet() if @$("#bet-amount").is(":enabled")
        #left key
        when 37 then @divideBet()  if @$("#bet-amount").is(":enabled")
        #w key
        when 87 then @onGoToWarClick() if @$("#go-to-war-bt").is(":visible")
        #s key
        when 83 then $.publish "surrender" if @$("#surrender-bt").is(":visible")
        #space key
        when 32 then ev.preventDefault() or @toggleBetOnTie()

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]

  onGameResult: (ev, result)=>
    @renderGameResult result
