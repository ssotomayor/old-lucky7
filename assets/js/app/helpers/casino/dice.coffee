window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.Casino = window.App.Helpers.Casino or {}
window.App.Helpers.Casino.Dice = window.App.Helpers.Casino.Dice or {}

App.Helpers.Casino.Dice =

  MIN_DICE_VALUE: 0
  MAX_DICE_VALUE: 1000000
  RETURN_TO_PLAYER: 0.99
  MIN_CHANCE: 0.0099
  MAX_CHANCE: 0.97
  MAX_PROFIT_MULTIPLIER: 0.2 # MaxProfit = 0.2 * MaxCap

  getReturnToPlayer: ()->
    @RETURN_TO_PLAYER

  getMaxDiceValue: ()->
    @MAX_DICE_VALUE

  getMinChance: ()->
    @MIN_CHANCE

  getMaxChance: ()->
    @MAX_CHANCE

  getMinPayout: ()->
    _.str.roundTo @calculatePayout(@MAX_CHANCE), 8

  getMaxPayout: ()->
    _.str.roundTo @calculatePayout(@MIN_CHANCE), 8

  getMinWager: ()->
    CONFIG.minCap

  getMaxWager: ()->
    CONFIG.maxCap

  getMinProfit: ()->
    CONFIG.minCap

  getMaxProfit: ()->
    CONFIG.maxCap * @MAX_PROFIT_MULTIPLIER

  calculateLowTarget: (chance)->
    parseInt(@MAX_DICE_VALUE * chance, 10)

  calculateHighTarget: (chance)->
    parseInt(@MAX_DICE_VALUE * (1 - chance) , 10) - 1

  calculateProfit: (wager, payout)->
    _.str.roundTo wager * (payout - 1), 8

  calculateChance: (payout)->
    _.str.roundTo @RETURN_TO_PLAYER / payout, 8

  calculatePayout: (chance)->
    _.str.roundTo @RETURN_TO_PLAYER / chance, 8

  calculateWager: (profit, payout)->
    _.str.roundTo profit / (payout - 1), 8

  isValidWager: (wager)->
    wager >= CONFIG.minCap and wager <= CONFIG.maxCap

  isValidChance: (chance)->
    chance >= @getMinChance() and chance <= @getMaxChance()

  isValidProfit: (profit)->
    profit >= CONFIG.minCap and profit <= CONFIG.maxCap * @MAX_PROFIT_MULTIPLIER

  getValidationErrors: (data)->
    messages = []
    wager = data.amount
    payout = data.multiplier
    chance = @calculateChance payout
    profit = @calculateProfit wager, payout
    if not @isValidChance(chance)
      messages.push "Chance must be between #{@getMinChance()} and #{@getMaxChance()}" 
    if not @isValidWager(wager)
      messages.push "Wager must be between #{@getMinWager()} and #{@getMaxWager()}"
    if not @isValidProfit profit
      messages.push "Profit must be between #{@getMinProfit()} and #{@getMaxProfit()}"
    return messages