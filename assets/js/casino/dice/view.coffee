window.Dice or= {}

class window.Dice.View extends App.MasterView

  el: null

  tpl: null

  player: null

  helper: App.Helpers.Casino.Dice

  events:
    "click #roll-hi-bt": "onRollHighClick"
    "click #roll-lo-bt": "onRollLowClick"

    "keyup #bet-amount": "onBetAmountChange"
    "keyup #chance-amount": "onChanceAmountChange"
    "keyup #payout-amount": "onPayoutAmountChange"
    "keyup #profit-amount": "onProfitAmountChange"

    "click #chance-min" : "onChanceMinClick"
    "click #chance-decrease" : "onChanceDecreaseClick"
    "click #chance-increase" : "onChanceIncreaseClick"
    "click #chance-max" : "onChanceMaxClick"
    "click #bet-min" : "onBetMinClick"
    "click #bet-halve" : "onBetHalveClick"
    "click #bet-double" : "onBetDoubleClick"
    "click #bet-max" : "onBetMaxClick"

  initialize: ({@tpl, @provablyFair, @player})->
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @hideBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "roll"

  renderGameResult: (gameResult)->
    @renderDice gameResult, ()=>
      @renderWinLostAmount gameResult
      @renderResultHistory gameResult
      $.publish "balance-updated", gameResult.balance

  renderWinLostAmount: (gameResult)->
    @tpl = "dice-game-result-tpl"
    @$("#game-result-cnt").html @template({gameResult: gameResult})

  renderResultHistory: (gameResult)->
    $last = @$("#game-history-cnt tr:last")
    $next = $last.clone()
    $next.find(".dice-bet").text gameResult.wager
    $next.find(".dice-target").text @getRollTarget(gameResult)
    $next.find(".dice-roll").text @formatRoll(gameResult.roll)
    $next.find(".dice-roll").removeClass "dice-lose dice-win"
    $next.find(".dice-roll").addClass "dice-#{gameResult.result}"
    $next.find(".dice-payout").text "#{gameResult.multiplier}x"
    $next.find(".dice-profit").text gameResult.profit
    $next.find(".dice-profit").removeClass "dice-lose dice-win"
    $next.find(".dice-profit").addClass "dice-#{gameResult.result}"
    @$("#game-history-cnt").prepend $next
    $last.remove()

  formatRoll: (value)->
    return "?" if not _.isNumber(value) or _.isNaN(value)
    num = @getNumber(value)
    dec = @getDecimals(value)
    "#{num}.#{dec}"

  getRollTarget: (gameResult)->
    target = gameResult["#{gameResult.target}_target"]
    target = "> #{@formatRoll(target)}" if gameResult.target is "hi"
    target = "< #{@formatRoll(target)}" if gameResult.target is "lo"
    target

  showBetChoices: ()->
    @$("#bet-choices").removeClass("disabled")
    @$("#bet-choices .action, #bet-choices input").removeAttr("disabled")

  hideBetChoices: ()->
    @$("#bet-choices").addClass("disabled")
    @$("#bet-choices .action, #bet-choices input").attr("disabled","disabled")

  cleanTable: ()->
    @$(".winner").removeClass "winner"
    @$("#game-result-cnt").empty()

  renderDice: (gameResult, callback = ()->)->
    value = gameResult.roll
    result = gameResult.result
    intervalId = setInterval(@setRandomDiceValue, 50)
    duration = @getRandomInt(250, 1000)
    setTimeout((
      ()=>
        clearInterval intervalId
        @setDiceValue value
        @$("#big-dice").addClass(result)
        callback()
      )
      , duration)

  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  setRandomDiceValue: ()=>
    value = @getRandomInt(1, 999999)
    @setDiceValue value

  setDiceValue: (value)->
    $number = @$(".number")
    $decimals = @$(".decimals")
    $number.text @getNumber(value)
    $decimals.text ".#{@getDecimals(value)}"

  padZeroes: (num, size)->
    return ("000000000" + num).substr(-size)

  getNumber: (num)->
    parseInt num / 10000

  getDecimals: (num)->
    @padZeroes(num % 10000, 4)
  
  clearDiceColor: ()->
    @$("#big-dice").removeClass("win").removeClass("lose")

  rollDice: (target)->
    @cleanTable()
    wager = {}
    wager.target = target
    wager.amount = @getWager()
    wager.multiplier = @getPayout()
    clientSeed = @provablyFair.getClientSeed()
    $.publish "roll", [wager, clientSeed]
    
  setLoHighTargets: (chance)->
    highTarget = @helper.calculateHighTarget(chance)
    lowTarget = @helper.calculateLowTarget(chance)
    @$("#roll-hi-value").text "> #{@formatRoll(highTarget)}"
    @$("#roll-lo-value").text "< #{@formatRoll(lowTarget)}"
  
  getWager: ()->
    $amount = @$("#bet-amount")
    amount = parseFloat $amount.val()
    return 0  if _.isNaN(amount)
    amount = _.str.roundToThree amount
    amount

  setWager: (wager)->
    $wager = @$("#bet-amount")
    $wager.val(_.str.roundToThree(wager))  if @helper.isValidWager(wager)

  getPayout: ()->
    $payout = @$("#payout-amount")
    payout = parseFloat $payout.val()
    return 0  if _.isNaN(payout)
    payout = _.str.roundToThree payout
    payout

  setPayout: (payout)->
    $payout = @$("#payout-amount")
    $payout.val _.str.roundToThree payout

  getChance: ()->
    $chance = @$("#chance-amount")
    chance = parseFloat $chance.val()
    return 0  if _.isNaN(chance)
    chance = _.str.roundTo chance / 100, 4

  setChance: (chance)->
    $chance = @$("#chance-amount")
    chancePercent = _.str.roundTo(chance * 100, 2)
    $chance.val(chancePercent)  if @helper.isValidChance(chance)

  getProfit: ()->
    $profit = @$("#profit-amount")
    profit = parseFloat $profit.val()
    return 0  if _.isNaN(profit)
    profit = _.str.roundToThree profit
    profit

  setProfit: (profit)->
    $profit = @$("#profit-amount")
    $profit.val _.str.roundToThree profit

  onRollLowClick: (ev)=>
    ev.preventDefault()
    @rollDice("lo")

  onRollHighClick: (ev)=>
    ev.preventDefault()
    @rollDice("hi")

  onBetAmountChange: (ev)=>
    wager = @getWager()
    payout = @getPayout()
    @setProfit @helper.calculateProfit(wager, payout)
  
  onPayoutAmountChange: (ev)=>
    payout = @getPayout()
    if payout < @helper.getMinPayout()
      payout = @helper.getMinPayout()
      @setPayout payout
    if payout > @helper.getMaxPayout()
      payout = @helper.getMaxPayout()
      @setPayout payout
    wager = @getWager()
    chance = @helper.calculateChance(payout)
    @setProfit @helper.calculateProfit(wager, payout)
    @setChance chance
    @setLoHighTargets chance

  onChanceAmountChange: (ev)=>
    chance = @getChance()
    if chance < @helper.getMinChance()
      chance = @helper.getMinChance()
      @setChance chance
    if chance > @helper.getMaxChance()
      chance = @helper.getMaxChance()
      @setChance chance
    wager = @getWager()
    payout = @helper.calculatePayout(chance)
    @setProfit @helper.calculateProfit(wager, payout)
    @setLoHighTargets chance
    @setPayout payout
  
  onProfitAmountChange: (ev)=>
    profit = @getProfit()
    payout = @getPayout()
    wager = @helper.calculateWager(profit, payout)
    @setWager wager

  onGameResult: (ev, result)=>
    @renderGameResult result

  onChanceMinClick: (ev)=>
    ev.preventDefault()
    @setChance @helper.getMinChance()
    @onChanceAmountChange(ev)

  onChanceDecreaseClick: (ev)=>
    ev.preventDefault()
    @setChance @getChance() - 0.01
    @onChanceAmountChange(ev)

  onChanceIncreaseClick: (ev)=>
    ev.preventDefault()
    @setChance @getChance() + 0.01
    @onChanceAmountChange(ev)

  onChanceMaxClick: (ev)=>
    ev.preventDefault()
    @setChance @helper.getMaxChance()
    @onChanceAmountChange(ev)

  onBetMinClick: (ev)=>
    ev.preventDefault()
    payout = @getPayout()
    minWager = CONFIG.minCap
    minProfit = @helper.calculateProfit(minWager, payout)
    if minProfit < CONFIG.minCap
      minWager = @helper.calculateWager(CONFIG.minCap, payout)
      minProfit = CONFIG.minCap
    @setWager minWager
    @setProfit minProfit
    @onBetAmountChange(ev)

  onBetHalveClick: (ev)=>
    ev.preventDefault()
    @setWager @getWager() / 2
    @onBetAmountChange(ev)

  onBetDoubleClick: (ev)=>
    ev.preventDefault()
    @setWager @getWager() * 2
    @onBetAmountChange(ev)

  onBetMaxClick: (ev)=>
    ev.preventDefault()
    payout = @getPayout()
    maxWager = Math.min(@helper.getMaxWager(), @player.get("balance"))
    maxProfit = @helper.calculateProfit(maxWager, payout)
    if maxProfit > @helper.getMaxProfit()
      maxProfit = @helper.getMaxProfit()
      maxWager = @helper.calculateWager(maxProfit, payout)
    @setWager maxWager
    @setProfit maxProfit
    @onBetAmountChange(ev)
  
  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        # H
        when 72 then @rollDice("hi") if @$("#roll-hi-bt").is(":enabled")
        # L
        when 76 then @rollDice("lo") if @$("#roll-lo-bt").is(":enabled")

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount", "chance-amount", "payout-amount", "profit-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]
