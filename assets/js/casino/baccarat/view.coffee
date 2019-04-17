window.Baccarat or= {}

class window.Baccarat.View extends App.MasterView

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
    $bets = @$("[data-bet]")
    $bets.click @onBetItemClick
    $bets.bind "contextmenu", @onBetItemRightClick
    $bets.hover @onBetOver, @onBetOut
    App.Helpers.Sound.load "chips"
    App.Helpers.Sound.load "deal"

  renderGameResult: (gameResult)->
    @renderWinLostChips gameResult.result
    @renderWinLostAmount gameResult.won_amount, gameResult.lost_amount

  renderWinLostAmount: (wonAmount, lostAmount)->
    @tpl = "baccarat-game-result-tpl"
    @$("#game-result-cnt").html @template({wonAmount: wonAmount, lostAmount: lostAmount})

  renderWinLostChips: (luckyWager)->
    @$("[data-bet='#{luckyWager}']").addClass "winner"
    wagers = @collectWagers()
    for wagerType, wagerAmount of wagers
      if wagerType is luckyWager
        classToAdd = "won"
      else if wagerType isnt luckyWager and luckyWager isnt "tie"
        classToAdd = "lost"
      else
        classToAdd = ""
      @$("[data-bet='#{wagerType}'] > .chips:first").addClass classToAdd  if classToAdd

  renderBankerCard: (card = {})->
    @renderCard card, @$("#banker-cards")

  renderPlayerCard: (card = {})->
    @renderCard card, @$("#player-cards")

  renderCard: (card = {}, $el)->
    @tpl = "baccarat-card-tpl"
    $el.append @template({card: card})
    App.Helpers.Sound.play "deal"  if not card.noanim
  
  renderBankerScore: (score)->
    @$("#banker-score").text score

  renderPlayerScore: (score)->
    @$("#player-score").text score

  clearBankerCards: ()->
    @$("#banker-cards").empty()

  clearPlayerCards: ()->
    @$("#player-cards").empty()

  clearScores: ()->
    @$("#banker-score,#player-score,#game-result-cnt,#game-score-cnt").empty()

  showBetChoices: ()->
    @$("#bet-choices").removeClass("disabled")
    @$("#bet-choices .action, #bet-choices input").removeAttr("disabled")

  hideBetChoices: ()->
    @$("#bet-choices").addClass("disabled")
    @$("#bet-choices .action, #bet-choices input").attr("disabled","disabled")

  getLastSelectedBet: ()->
    @$(".last-selected-bet:last")

  markLastSelected: ($el)->
    @getLastSelectedBet().removeClass "last-selected-bet"
    $el.addClass "last-selected-bet"
    $el.trigger "mouseover"

  getBetElements: ()->
    @$bets = @$("[data-bet]") if not @$bets
    @$bets

  getBetMaxCap: (betType)->
    parseInt CONFIG.maxCap

  getBetPerClickAmount: ()->
    _.str.roundToThree @$("#betperclick-amount").val()

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
      $chips = $selectedBet.find(".chips").removeClass("won").removeClass("lost")
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

  cleanTable: ()->
    @clearBankerCards()
    @clearPlayerCards()
    @clearScores()
    @$(".winner").removeClass "winner"
    @$("#game-result-cnt").empty()
    @$(".chips").each (index, el)->
      $(el).removeClass("won").removeClass("lost")

  collectWagers: ()->
    wagers = {}
    $bets = @getBetElements()
    for bet in $bets
      $bet = $(bet)
      $chips = $bet.find(".chips:first")
      wagers[$bet.data("bet")] = _.str.roundToThree($chips.text()) if $chips.text() isnt ""
    wagers

  calculateTotalWager: ()->
    totalWager = 0
    $bets = @getBetElements()
    for bet in $bets
      $bet = $(bet)
      $chips = $bet.find(".chips:first")
      totalWager = _.str.roundToThree(totalWager + _.str.roundToThree($chips.text())) if $chips.text() isnt ""
    totalWager

  deal: ()->
    @cleanTable()
    wagers = @collectWagers()
    clientSeed = @provablyFair.getClientSeed()
    $.publish "deal", [wagers, clientSeed]

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
    @deal()

  onClearClick: (ev)=>
    ev.preventDefault()
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
        when 13 then @deal() if @$("#bet-bt").is(":enabled")
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

  onBetOver: (ev)->
    $target = $(ev.currentTarget)
    viewId = $target.attr("id").replace("bet-", "")
    $("##{viewId}").addClass "highlight"

  onBetOut: (ev)->
    $target = $(ev.currentTarget)
    viewId = $target.attr("id").replace("bet-", "")
    $("##{viewId}").removeClass "highlight"
