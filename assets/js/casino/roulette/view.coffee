window.Roulette or= {}

class window.Roulette.View extends App.MasterView

  localStoragePath: "satoshibet.roulette.game_state"

  el: null

  tpl: null

  player: null

  events:
    "click #bet-bt": "onBetClick"
    "click #clear-bt": "onClearClick"
    "click #bet-plus": "onBetIncreaserClick"
    "click #bet-minus": "onBetDecreaserClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"
    "click #bet-max": "onBetMaxClick"
    "keyup #bet-amount": "onBetAmountChange"
    "keyup #betperclick-amount": "onBetPerClickAmountChange"
    "blur #betperclick-amount": "onBetPerClickAmountBlur"

  initialize: ({@tpl, @provablyFair, @player})->
    $.subscribe "game-result", @onGameResult

  renderGameTable: ()->
    @hideBetChoices()
    @$("#bet-sizer").hover @onBetSizerMouseEnter, @onBetSizerMouseLeave
    $(window).keydown @onKeydown
    $board = @$("#board")
    $board.on "click", "[data-bet]", @onBetItemClick
    $board.on "hover", "[data-bet]", @onBetOver
    $board.on "contextmenu", "[data-bet]", @onBetItemRightClick
    App.Helpers.Sound.load "chips"
    App.Helpers.Sound.load "spinning"

  renderGameResult: (gameResult)->
    @renderLuckyNumber gameResult.numbers[0]
    @renderWinLostChips gameResult
    @renderWinLostAmount gameResult.won_amount, gameResult.lost_amount

  renderLuckyNumber: (luckyNumber)->
    @tpl = "roulette-lucky-number-tpl"
    @$("#lucky-numbers-cnt").prepend @template({luckyNumber: luckyNumber, luckyNumberColor: @getNumberColor(luckyNumber)})
    @$("#lucky-numbers-cnt").children().slice(8).remove()
    @$("#num-#{luckyNumber}").addClass "winner"

  renderWinLostAmount: (wonAmount, lostAmount)->
    @tpl = "roulette-game-result-tpl"
    @$("#game-result-cnt").html @template({wonAmount: wonAmount, lostAmount: lostAmount})

  renderWinLostChips: (gameResult)->
    luckyWagers = gameResult.result
    wagers = @collectWagers()
    for wagerType, wagerAmount of wagers
      classToAdd = if luckyWagers[wagerType] then "won" else "lost"
      @$("[data-bet='#{wagerType}'] > .chips:first").addClass classToAdd

  showBetChoices: ()->
    @$("#bet-choices").removeClass("disabled")
    @$("#bet-choices .action, #bet-choices input").removeAttr("disabled")

  hideBetChoices: ()->
    @$("#bet-choices").addClass("disabled")
    @$("#bet-choices .action, #bet-choices input").attr("disabled","disabled")

  getNumberColor: (number)->
    return "green" if number is 0
    reds = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
    if reds.indexOf(parseInt(number)) > -1 then "red" else "black"

  getLastSelectedBet: ()->
    @$(".last-selected-bet:last")

  getLastSelectedBetName: ()->
    @$(".last-selected-bet:last").data("bet")

  markLastSelected: ($el)->
    @getLastSelectedBet().removeClass "last-selected-bet"
    $el.addClass "last-selected-bet"
    $el.trigger "mouseover"

  markLastSelectedName: (name)->
    $target = @$("[data-bet=#{name}]")
    @markLastSelected $target

  getBetMaxCap: (betType)->
    if @isInsideBetType(betType) then parseInt(CONFIG.maxInsideCap) else parseInt CONFIG.maxCap

  getBetPerClickAmount: ()->
    _.str.roundToThree @$("#betperclick-amount").val()

  setBetPerClickAmount: (amount)->
    amount = _.str.roundToThree(parseFloat(amount))
    @$("#betperclick-amount").val amount

  isInsideBetType: (betType)->
    insideBetTypes = ["straight", "corner", "street", "line", "splitv", "splith"]
    for insideBetType in insideBetTypes
      return true if betType.indexOf(insideBetType) > -1
    false

  increaseBet: ()->
    $selectedBet = @getLastSelectedBet()
    if $selectedBet.length
      $chips = $selectedBet.find(".chips").removeClass("won").removeClass("lost")
      wager = if $chips.text() then _.str.roundToThree($chips.text()) else 0
      wager = _.str.roundToThree(wager + @getBetPerClickAmount())
      $chips.text(wager).show()
      @updateBetAmountInput wager
      @updateTotalBetAmount()
      App.Helpers.Sound.play "chips"

  decreaseBet: ()->
    $selectedBet = @getLastSelectedBet()
    if $selectedBet.length
      $chips = $selectedBet.find(".chips").removeClass("won").removeClass("lost")
      wager = if $chips.text() then _.str.roundToThree($chips.text()) else 0
      wager = _.str.roundToThree(wager - @getBetPerClickAmount())
      if wager >= CONFIG.minCap
        $chips.text(wager).show()
        App.Helpers.Sound.play "chips"
      else
        $chips.text("").hide()
        wager = 0
      @updateBetAmountInput wager
      @updateTotalBetAmount()

  multiplyBet: ()->
    $selectedBet = @getLastSelectedBet()
    if $selectedBet.length
      $chips = $selectedBet.find(".chips").removeClass("won").removeClass("lost")
      wager = if $chips.text() then _.str.roundToThree($chips.text()) else 1
      wager = _.str.roundToThree(wager * 2)
      $chips.text(wager).show()
      @updateBetAmountInput wager
      @updateTotalBetAmount()
      App.Helpers.Sound.play "chips"

  divideBet: ()->
    $selectedBet = @getLastSelectedBet()
    if $selectedBet.length
      $chips = $selectedBet.find(".chips").removeClass("won").removeClass("lost")
      wager = if $chips.text() then _.str.roundToThree($chips.text()) else 1
      wager = _.str.roundToThree(wager / 2)
      if wager >= CONFIG.minCap
        $chips.text(wager).show()
        App.Helpers.Sound.play "chips"
      else
        $chips.text("").hide()
        wager = 0
      @updateBetAmountInput wager
      @updateTotalBetAmount()

  maxBet: ()->
    $selectedBet = @getLastSelectedBet()
    if $selectedBet.length and @player.get("balance") > 0
      $chips = $selectedBet.find(".chips")
      allowedBalance = @player.get("balance") - @calculateTotalWager()
      allowedBalance = if allowedBalance < 0 then @player.get("balance") else allowedBalance
      maxCap = @getBetMaxCap $selectedBet.data "bet"
      if allowedBalance < maxCap
        wager = allowedBalance
      else
        wager = maxCap
      initialWager = $chips.text()
      $chips.text(wager).show()
      @updateBetAmountInput wager
      @updateTotalBetAmount()
      App.Helpers.Sound.play "chips"

  clearBets: ()->
    @getBetElements().find(".chips").each (index, el)->
      $(el).text("").hide().removeClass("won").removeClass("lost")
    @updateTotalBetAmount()
    App.Helpers.Sound.play "chips"

  updateBetAmountInput: (amount)->
    @$("#bet-amount").val amount

  getBetAmountInput: ()->
    @$("#bet-amount").val()

  updateTotalBetAmount: ()->
    $betSize = @$("#bet-size")
    $betValue = $betSize.find("#bet-size-value")
    totalWager = @calculateTotalWager()
    $betValue.text totalWager
    if totalWager > 0
      $betSize.show()
    else
      $betSize.hide()

  updateBetAmountChips: (amount)->
    if amount is 0
      @getLastSelectedBet().find(".chips").text("").hide()
        .removeClass("won").removeClass("lost")
    else
      @getLastSelectedBet().find(".chips").text(amount).show()
        .removeClass("won").removeClass("lost")

  spinTheWheel: (gameResult)->
    luckyNumber = gameResult.numbers[0]
    $wheel = @$("#wheel")
    $ball = $wheel.find("#ball")
    showenSquares = 10
    squareWidth = $wheel.find(":first").outerWidth()
    spinWidth = $wheel.width() - showenSquares * squareWidth
    $wheel.animate {"left": -spinWidth},
      speed: "slow"
      easing: "easeInQuint"
      complete: ()->
        $wheel.find("[data-num='#{luckyNumber}']")
        .find(".bucket").prepend $ball
        App.Helpers.Sound.play "spinning"
        $wheel.css("left", 0).animate {"left": -spinWidth},
          easing: "linear"
          complete: ()->
            $wheel.css("left", 0).animate {"left": -spinWidth},
              easing: "linear"
              complete: ()->
                $wheel.css("left", 0).animate {"left": -spinWidth},
                  easing: "linear"
                  complete: ()->
                    $wheel.css("left", 0).animate {"left": -spinWidth},
                      speed: "slow"
                      easing: "easeOutQuad"
                      complete: ()->
                        lastSpinWidth = squareWidth * luckyNumber - showenSquares / 2 * squareWidth + squareWidth
                        lastSpinWidth = if lastSpinWidth > spinWidth then spinWidth else lastSpinWidth
                        if lastSpinWidth > 0
                          $wheel.css("left", 0).animate {"left": -lastSpinWidth}, {speed: "slow", easing: "easeOutQuad"}
                        else
                          $wheel.css("left", 0)

  cleanTable: ()->
    @$(".winner").removeClass "winner"
    @$("#game-result-cnt").empty()
    @$(".board .chips").each (index, el)->
      $(el).removeClass("won").removeClass("lost")

  collectWagers: ()->
    wagers = {}
    $bets = @getBetElements()
    for bet in $bets
      $bet = $(bet)
      $chips = $bet.find(".chips:first")
      wagers[$bet.data("bet")] = _.str.roundToThree($chips.text()) if $chips.text() isnt ""
    wagers

  restoreWagers: (wagers)->
    for wager, amount of wagers
      $bet = @$("[data-bet=#{wager}]")
      $chips = $bet.find(".chips:first")
      $chips.text(amount).show()

  calculateTotalWager: ()->
    totalWager = 0
    $bets = @getBetElements()
    for bet in $bets
      $bet = $(bet)
      $chips = $bet.find(".chips:first")
      totalWager = _.str.roundToThree(totalWager + _.str.roundToThree($chips.text())) if $chips.text() isnt ""
    totalWager

  startSpinning: ()->
    @cleanTable()
    wagers = @collectWagers()
    clientSeed = @provablyFair.getClientSeed()
    $.publish "spin", [wagers, clientSeed]

  saveTableState: ()->
    return if not !!window.localStorage
    window.localStorage.setItem "#{@localStoragePath}.bet-amount", @getBetAmountInput()
    window.localStorage.setItem "#{@localStoragePath}.bet-per-click", @getBetPerClickAmount()
    window.localStorage.setItem "#{@localStoragePath}.last-bet", @getLastSelectedBetName()
    window.localStorage.setItem "#{@localStoragePath}.wagers", JSON.stringify(@collectWagers())

  clearTableState: ()->
    return if not !!window.localStorage
    window.localStorage.removeItem "#{@localStoragePath}.bet-amount"
    window.localStorage.removeItem "#{@localStoragePath}.bet-per-click"
    window.localStorage.removeItem "#{@localStoragePath}.last-bet"
    window.localStorage.removeItem "#{@localStoragePath}.wagers"

  restoreTableState: ()->
    return if not !!window.localStorage
    betAmount      = window.localStorage.getItem("#{@localStoragePath}.bet-amount")
    betPerClick    = window.localStorage.getItem("#{@localStoragePath}.bet-per-click")
    lastBet        = window.localStorage.getItem("#{@localStoragePath}.last-bet")
    wagers         = window.localStorage.getItem("#{@localStoragePath}.wagers")
    @restoreWagers(JSON.parse(wagers))  if wagers
    @updateBetAmountInput(parseFloat(betAmount))  if betAmount
    @setBetPerClickAmount(parseFloat(betPerClick))  if betPerClick
    @markLastSelectedName(lastBet)  if lastBet
    @updateTotalBetAmount()

  onBetItemClick: (ev)=>
    $target = $(ev.currentTarget)
    @markLastSelected($target)
    @increaseBet()
    @showBetChoices()

  onBetItemRightClick: (ev)=>
    ev.preventDefault()
    $target = $(ev.currentTarget)
    @markLastSelected($target)
    @decreaseBet()

  onBetSizerMouseEnter: (ev)=>
    ev.preventDefault()
    $target = @getLastSelectedBet()
    $target.trigger "mouseenter"

  onBetSizerMouseLeave: (ev)=>
    ev.preventDefault()
    $target = @getLastSelectedBet()
    $target.trigger "mouseleave"

  onBetClick: (ev)=>
    ev.preventDefault()
    @saveTableState()
    @startSpinning()

  onClearClick: (ev)=>
    ev.preventDefault()
    @clearTableState()
    @clearBets()

  onBetIncreaserClick: (ev)=>
    ev.preventDefault()
    @increaseBet()

  onBetDecreaserClick: (ev)=>
    ev.preventDefault()
    @decreaseBet()

  onBetDividerClick: (ev)=>
    ev.preventDefault()
    @divideBet()

  onBetMultiplierClick: (ev)=>
    ev.preventDefault()
    @multiplyBet()

  onBetMaxClick: (ev)=>
    ev.preventDefault()
    @maxBet()

  onBetAmountChange: (ev)=>
    value = $(ev.target).val()
    amount = _.str.roundToThree value
    if value[value.length - 1] isnt "." and _.isNumber(amount) and amount <= CONFIG.maxCap and amount >= CONFIG.minCap
      $(ev.target).val amount
      @updateBetAmountChips(amount)
      @updateTotalBetAmount()
    else
      @updateBetAmountChips(0)
      @updateTotalBetAmount()

  onBetPerClickAmountChange: (ev)=>
    value = $(ev.target).val()
    amount = _.str.roundToThree value
    amount = CONFIG.minCap  if amount < CONFIG.minCap
    amount = CONFIG.maxCap  if amount > CONFIG.maxCap
    if value[value.length - 1] isnt "." and value[value.length - 1] isnt "0" and _.isNumber(amount) and not isNaN amount
      $(ev.target).val amount

  onBetPerClickAmountBlur: (ev)=>
    value = $(ev.target).val()
    amount = _.str.roundToThree value
    if not _.isNumber(amount) or isNaN amount
      $(ev.target).val 1

  onGameResult: (ev, result)=>
    @renderGameResult result

  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        #enter
        when 13 then @startSpinning() if @$("#bet-bt").is(":enabled")
        #space
        when 32 then @clearBets() if @$("#clear-bt").is(":enabled")
        #right key
        when 39 then @multiplyBet() if @$("#bet-multiplier").is(":enabled")
        #left key
        when 37 then @divideBet() if @$("#bet-divider").is(":enabled")
        #up key
        when 38 then @increaseBet() if @$("#bet-plus").is(":enabled")
        #down key
        when 40 then @decreaseBet() if @$("#bet-minus").is(":enabled")

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]

  isBetType: (betType, $el)->
    $el.data("bet").indexOf("#{betType}_") > -1

  onBetOver: (ev)=>
    $target = $(ev.currentTarget)
    viewId = $target.attr("id").replace("bet-", "")
    $("##{viewId}").toggleClass "highlight", ev.type is "mouseenter"
    return @unHighlightNumbers()      if ev.type is "mouseleave"
    return @highlightColumn $target   if @isBetType "column", $target
    return @highlightDozen $target    if @isBetType "dozen", $target
    return @highlightLowHigh $target  if @isBetType "lowHigh", $target
    return @highlightEvenOdd $target  if @isBetType "evenOdd", $target
    return @highlightColor $target    if @isBetType "color", $target
    return @highlightStreet $target   if @isBetType "street", $target
    return @highlightLine $target     if @isBetType "line", $target
    return @highlightCorner $target   if @isBetType "corner", $target
    return @highlightSplitV $target   if @isBetType "splitv", $target
    return @highlightSplitH $target   if @isBetType "splith", $target


  # Element cachers

  getBetElements: ()->
    @$bets = @$("[data-bet]")  if not @$bets
    @$bets

  getNumberElements: (includeGreen = false)->
    @$numbers = @$(".board .number") if not @$numbers
    @$numbersWithZero = @$numbers.add(".board .green") if not @$numbersWithZero
    if includeGreen then @$numbersWithZero else @$numbers

  getGreenNumber: ()->
    @$greenNumber = @getNumberElements(true).filter(".green")  if not @$greenNumber
    $(@$greenNumber)

  getCachedElements: (type, keyNumber, callback, includeZero = false)->
    cacheKey = "$#{type}-#{keyNumber}-Elements"
    @[cacheKey] = _.filter @getNumberElements(includeZero), callback  if not @[cacheKey]
    $(@[cacheKey])

  getColumnElements: (columnNumber)->
    @getCachedElements "column", columnNumber, (el)->
      number = parseInt $(el).text()
      numberColumn = if number % 3 is 0 then 3 else number % 3
      numberColumn is columnNumber

  getDozenElements: (dozenNumber)->
    @getCachedElements "dozen", dozenNumber, (el)->
      number = parseInt $(el).text()
      number <= (dozenNumber * 12) and number >= (dozenNumber * 12 - 11)

  getLowHighElements: (rangeNumber)->
    @getCachedElements "lowHigh", rangeNumber, (el)->
      number = parseInt $(el).text()
      (rangeNumber is "low" and number < 19) or (rangeNumber is "high" and number > 18)

  getEvenOddElements: (rangeNumber)->
    @getCachedElements "evenOdd", rangeNumber, (el)->
      number = parseInt $(el).text()
      (rangeNumber is "even" and number % 2 is 0) or (rangeNumber is "odd" and number % 2 isnt 0)

  getColorElements: (color)->
    @getCachedElements "color", color, (el)->
      $(el).hasClass color

  getStreetElements: (streetNumber)->
    @getCachedElements "street", streetNumber, (el)->
      number = parseInt $(el).text()
      number <= (streetNumber * 3) and number >= (streetNumber * 3 - 2)

  getLineElements: (lineNumber)->
    cb = (el)->
      number = parseInt $(el).text()
      number <= (lineNumber * 3) and number >= (lineNumber * 3 - 5)
    @getCachedElements "line", lineNumber, cb, true

  getCornerElements: (cornerNumber)->
    validNumbers = [cornerNumber, cornerNumber + 1, cornerNumber + 4, cornerNumber + 3]
    cb = (el)->
      number = parseInt $(el).text()
      validNumbers.indexOf(number) > -1
    @getCachedElements "corner", cornerNumber, cb, true

  getSplitVElements: (splitNumber)->
    cb = (el)->
      number = parseInt $(el).text()
      number is splitNumber or number is (splitNumber + 3)
    @getCachedElements "splitV", splitNumber, cb, true

  getSplitHElements: (splitNumber)->
    @getCachedElements "splitH", splitNumber, (el)->
      number = parseInt $(el).text()
      number is splitNumber or number is (splitNumber + 1)


  # Highlighters

  highlightColumn: ($el)->
    columnNumber = parseInt $el.data("bet").replace("column_", "")
    @getColumnElements(columnNumber).addClass("highlight")

  highlightDozen: ($el)->
    dozenNumber = parseInt $el.data("bet").replace("dozen_", "")
    @getDozenElements(dozenNumber).addClass("highlight")

  highlightLowHigh: ($el)->
    rangeNumber = $el.data("bet").replace("lowHigh_", "")
    @getLowHighElements(rangeNumber).addClass("highlight")

  highlightEvenOdd: ($el)->
    rangeNumber = $el.data("bet").replace("evenOdd_", "")
    @getEvenOddElements(rangeNumber).addClass("highlight")

  highlightColor: ($el)->
    color = $el.data("bet").replace("color_", "")
    @getColorElements(color).addClass("highlight")

  highlightStreet: ($el)->
    streetNumber = parseInt $el.data("bet").replace("street_", "")
    @getStreetElements(streetNumber).addClass("highlight")

  highlightLine: ($el)->
    lineNumber = parseInt $el.data("bet").replace("line_", "")
    @getLineElements(lineNumber).addClass("highlight")

  highlightCorner: ($el)->
    cornerNumber = parseInt $el.data("bet").replace("corner_", "")
    @getCornerElements(cornerNumber).addClass("highlight")
    @getGreenNumber().addClass("highlight")  if cornerNumber is -2

  highlightSplitV: ($el)->
    splitNumber = parseInt $el.data("bet").replace("splitv_", "")
    @getSplitVElements(splitNumber).addClass("highlight")
    @getGreenNumber().addClass("highlight")  if splitNumber is -1 or splitNumber is -2

  highlightSplitH: ($el)->
    splitNumber = parseInt $el.data("bet").replace("splith_", "")
    @getSplitHElements(splitNumber).addClass("highlight")

  unHighlightNumbers: ()->
    @getNumberElements(true).removeClass("highlight")
