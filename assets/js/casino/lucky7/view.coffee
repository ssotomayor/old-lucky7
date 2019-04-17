window.Lucky7 or= {}

class window.Lucky7.View extends App.MasterView

  el: null

  tpl: null

  spinSpeed: [3000, 3500, 4000]

  lastSpinLuckySymbols: ["l7", "l7", "l7"]

  sounds: {}

  isSpinning: false

  events:
    "click #bet-bt": "onBetClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"
    "click #bet-amount": "onBetAmountChange"

  initialize: ({@tpl, @provablyFair})->
    @tpl = "lucky7-game-result-tpl"
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @showBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "spinning"
    App.Helpers.Sound.load "payout", {loop: true}
    App.Helpers.Sound.load "fastpayout", {loop: true}

  renderGameResult: (gameResult)->
    isWin = gameResult.result.length > 0
    @isSpinning = false
    if isWin
      @$(".reels-wrapper:first").addClass "blink"
      @$("#game-result-cnt").html @template({gameResult: gameResult})
      if gameResult.charged_amount < 1
        @$("#payout").text gameResult.charged_amount
        _.delay ()=>
            @startAutoSpinning(isWin) if @isAutoSpin()
          ,
          180
      else
        @renderPayout 0, gameResult.charged_amount, ()=>
          @startAutoSpinning(isWin) if @isAutoSpin()
    else
      @startAutoSpinning(isWin) if @isAutoSpin()

  renderPayout: (payedAmount, totalFloatAmount, callback = ()->)=>
    totalAmount = Math.round(totalFloatAmount)
    payoutType = if totalAmount <= 50 then "payout" else "fastpayout"
    App.Helpers.Sound.play payoutType, {loop: true} if payedAmount is 0
    @$("#payout").text payedAmount
    App.Helpers.Sound.stop payoutType if payedAmount is totalAmount
    payedAmount++
    delayTime = if payoutType is "payout" then 180 else 10
    _.delay(@renderPayout, delayTime, payedAmount, totalFloatAmount, callback) if payedAmount <= totalAmount
    if payedAmount > totalAmount
      @$("#payout").text totalFloatAmount
      callback()

  hideBetChoices: ()->
    @$("#bet-choices .action:not(.autoplay), #bet-choices .betinput")
    .addClass("disabled")
    .attr
      disabled: "disabled"

  showBetChoices: ()->
    @$("#bet-choices .action, #bet-choices .betinput")
    .removeClass("disabled")
    .removeAttr("disabled")

  spinReels: (gameResult)->
    @spinSpeed = _.shuffle @spinSpeed
    index = 0
    while index < 3
      @spinReel index, gameResult.reels[index][0]
      index++
    @lastSpinLuckySymbols = [
      gameResult.reels[0][0]
      gameResult.reels[1][0]
      gameResult.reels[2][0]
    ]
    App.Helpers.Sound.play "spinning"

  spinReel: (index, luckySymbol)->
    $reel = @$(".reel:eq(#{index})")
    @setReelInitialPosition $reel, @lastSpinLuckySymbols[index]
    $symbolsWrapper = $reel.find(".symbols-wrapper:first")
    $symbol = $symbolsWrapper.find("[data-symbol='#{luckySymbol}']:first")
    symbolsHeight = 0
    for symbol in $symbol.prevAll()
      symbolsHeight -= $(symbol).height()
    currentSymbolHeight = $symbol.height()
    spinLength = symbolsHeight + currentSymbolHeight / 2
    $symbolsWrapper.animate {"top": spinLength}, @spinSpeed[index], "easeInOutCubic"

  setReelInitialPosition: ($reel, initialSymbol)->
    $symbolsWrapper = $reel.find(".symbols-wrapper:first")
    $symbol = $symbolsWrapper.find("[data-symbol='#{initialSymbol}']:last")
    symbolsHeight = 0
    for symbol in $symbol.prevAll()
      symbolsHeight -= $(symbol).height()
    currentSymbolHeight = $symbol.height()
    spinLength = symbolsHeight + currentSymbolHeight / 2
    $symbolsWrapper.css "top", spinLength

  cleanTable: ()->
    @$("#game-result-cnt").empty()
    @$(".reels-wrapper:first").removeClass "blink"

  startSpinning: ()=>
    return if @isSpinning is true
    @isSpinning = true

    @cleanTable()
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree $amount.val()
    $amount.val wager
    clientSeed = @provablyFair.getClientSeed()
    $.publish "spin", [wager, clientSeed]

  startAutoSpinning: (isWin)->
    autoSpinDelay = 500
    autoSpinDelay = 2000 if isWin
    setTimeout @startSpinning, autoSpinDelay

  multiplyBet: ()->
    $amount = @$("#bet-amount")
    wager = parseFloat $amount.val()
    $amount.val _.str.roundToThree(wager * 2)

  divideBet: ()->
    $amount = @$("#bet-amount")
    wager = parseFloat $amount.val()
    $amount.val _.str.roundToThree(wager / 2)

  isAutoSpin: ()->
    @$("#auto-play").is(":checked")

  toggleAutoSpin: ()->
    @$("#auto-play").attr "checked", !@isAutoSpin()

  onBetClick: (ev)=>
    ev.preventDefault()
    @startSpinning()

  onBetMultiplierClick: (ev)=>
    ev.preventDefault()
    @multiplyBet()

  onBetDividerClick: (ev)=>
    ev.preventDefault()
    @divideBet()

  onBetAmountChange: (ev)=>
    value = $(ev.target).val()
    amount = _.str.roundToThree value
    if value[value.length - 1] isnt "." and _.isNumber(amount) and amount <= CONFIG.maxCap and amount >= CONFIG.minCap
      $(ev.target).val amount

  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        #enter
        when 13 then @startSpinning() if @$("#bet-bt").is(":enabled")
        #right key
        when 39 then @multiplyBet() if @$("#bet-amount").is(":enabled")
        #left key
        when 37 then @divideBet() if @$("#bet-amount").is(":enabled")
        #space key
        when 32 then ev.preventDefault() or @toggleAutoSpin()

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]

  onGameResult: (ev, result)=>
    @renderGameResult result
