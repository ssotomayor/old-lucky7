window.Bombs or= {}

class window.Bombs.View extends App.MasterView

  el: null

  tpl: null

  player: null

  events:
    "click #start-game-bt": "onPlayClick"
    "click #take-profit-bt": "onCashoutClick"
    "click [data-bet]": "onFieldClick"
    "click #bet-multiplier": "onBetMultiplierClick"
    "click #bet-divider": "onBetDividerClick"
    "change #field-size": "onFieldSizeChange"

  initialize: ({@tpl, @provablyFair, @player})->
    $.subscribe "game-result", @onGameResult
    $.subscribe "step-result", @onStepResult

  renderGameTable: ()->
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "step"
    App.Helpers.Sound.load "bomb"

  removeAllFields: ()->
    @$("#board").empty()

  renderGameTable: ()->
    @showBetChoices()
    $(window).keydown @onKeydown
    App.Helpers.Sound.load "step"
    App.Helpers.Sound.load "bomb"
  
  renderFields: (response)->
    @removeAllFields()
    @tpl = "bombs-board-tpl"
    @$("#board").append @template({response: response})
    @renderTakeProfit response
    @setFieldSize response.cols, response.rows
  
  removeAllFields: ()->
    @$("#board").empty()

  renderGameResult: (gameResult)->
    @tpl = "dice-game-result-tpl"
    @$("#game-result-cnt").html @template({gameResult: gameResult})

  renderStepResult: (gameResult)->
    currentRow = gameResult.current_row
    bombPos = gameResult.bombs[currentRow - 1]
    stepPos = gameResult.steps[currentRow - 1]
    @renderRow gameResult.rows, currentRow, bombPos, stepPos
    @renderTakeProfit gameResult

  renderTakeProfit: (gameResult)->
    currentRow = gameResult.current_row or 0
    payout = gameResult.payouts[currentRow]  if gameResult.payouts
    result = gameResult.result
    value = "Take Profit"
    if (["win", "lose"].indexOf(result) is -1) and payout
      value = "Take #{_.str.roundToThree(payout)} #{CONFIG.currencySymbol}"
    @$("#take-profit-bt").text value

  renderRow: (rows, currentRow, bombPos, stepPos)->
    $currentRow = @$("div [row-id=#{currentRow}]")
    $nextRow = @$("div [row-id=#{currentRow + 1}]")  if currentRow < rows
    $currentRow.children(".field-box").removeClass("activerow").addClass("open")
    $currentRow.children("[data-bet=#{bombPos}]").addClass("bomb")
    if bombPos is stepPos
      $currentRow.children("[data-bet=#{bombPos}]").addClass("dead")
    else
      $currentRow.children("[data-bet=#{stepPos}]").addClass("step")
      $nextRow.children(".field-box").addClass("activerow")  if $nextRow

  playGame: ()->
    @$("#game-result-cnt").empty()
    cols = @getColumnsNumber()
    rows = @getRowsNumber()
    wager = @getWager()
    clientSeed = @provablyFair.getClientSeed()
    $.publish "play", [cols, rows, wager, clientSeed]

  stepOn: ($target)->
    fieldPos = $target.attr("data-bet")
    $.publish "step", fieldPos

  cashout: ()->
    #@$("#take-profit-bt").addClass("disabled").attr({"disabled", "disabled"})
    @$("#take-profit-bt").hide()
    @$(".activerow").removeClass "activerow"
    $.publish "cashout"

  setFieldSize: (cols, rows)->
    $fieldSize = @$("#field-size")
    $fieldSize.val "#{cols}x#{rows}"

  getColumnsNumber: ()->
    fieldSize = @$("#field-size").val()
    cols = fieldSize.split("x")[0]
    cols

  getRowsNumber: ()->
    fieldSize = @$("#field-size").val()
    rows = fieldSize.split("x")[1]
    rows

  getWager: ()->
    $amount = @$("#bet-amount")
    wager = _.str.roundToThree $amount.val()
    $amount.val wager
    wager

  showBetChoices: (action)->
    # @$("#bet-choices #input").removeClass("disabled").removeAttr("disabled")
    # for bt in @$("#bet-choices .action")
    #   $bt = $(bt)
    #   if allowedActions and allowedActions.indexOf($bt.data("action")) > -1
    #     $bt.removeClass("disabled").removeAttr("disabled")
    #     @$("#bet-choices #field-size").removeAttr("disabled")  if $bt.data("action") is "start-game"
    #   else
    #     $bt.addClass("disabled").attr("disabled","disabled")
    if action is "start-game"
      @$("#bet-choices #start-game-bt").show()
      @$("#bet-choices .field-size, #bet-choices .betinput, #bet-choices .operators").show()
      @$("#bet-choices #take-profit-bt").hide()
    if action is "take-profit"
      @$("#bet-choices #take-profit-bt").show()
      @$("#bet-choices #start-game-bt").hide()
      @$("#bet-choices .field-size, #bet-choices .betinput, #bet-choices .operators").hide()

  hideBetChoices: ()->
    # @$("#bet-choices #field-size").attr({"disabled": "disabled"})
    # @$("#bet-choices .action, #bet-choices input").addClass("disabled").attr("disabled","disabled")
    @$("#bet-choices .field-size, #bet-choices .betinput, #bet-choices .operators").hide()
    @$("#bet-choices #start-game-bt").hide()
    @$("#bet-choices #take-profit-bt").hide()

  multiplyBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() * 2)

  divideBet: ()->
    $amount = @$("#bet-amount")
    $amount.val _.str.roundToThree(@getWager() / 2)

  onPlayClick: (ev)=>
    ev.preventDefault()
    @playGame()

  onFieldClick: (ev)=>
    ev.preventDefault()
    $target = $(ev.currentTarget)
    if @canStepOn($target)
      @stepOn($target)

  canStepOn: ($target)->
    return true  if $target.hasClass("activerow")
    return false

  onCashoutClick: (ev)=>
    ev.preventDefault()
    @cashout()

  onFieldSizeChange: (ev)=>
    ev.preventDefault()
    cols = @getColumnsNumber()
    rows = @getRowsNumber()
    $.publish "re-shuffle", [cols, rows, null]

  onBetMultiplierClick: (ev)=>
    ev.preventDefault()
    @multiplyBet()

  onBetDividerClick: (ev)=>
    ev.preventDefault()
    @divideBet()

  onGameResult: (ev, result)=>
    @renderGameResult result

  onStepResult: (ev, result)=>
    @renderStepResult result

  onKeydown: (ev)=>
    if not @isFocusedOnFormFields(ev.target)
      switch ev.keyCode
        #enter
        when 13 then @playGame() if @$("#start-game-bt").is(":visible")
        #space key
        when 32 then @cashout() if @$("#take-profit-bt").is(":visible")
        #right key
        when 39 then @multiplyBet() if @$("#bet-multiplier").is(":visible")
        #left key
        when 37 then @divideBet() if @$("#bet-divider").is(":visible")

  isFocusedOnFormFields: (el)->
    $el = $(el)
    $el.attr("id") not in ["bet-amount"] and $el.get(0).nodeName in ["INPUT", "TEXTAREA"]
