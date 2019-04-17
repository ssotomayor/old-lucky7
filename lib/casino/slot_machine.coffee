_         = require "underscore"
_s        = require "../underscore_string"
AppHelper = require "../app_helper"

_.deepClone     = (arrToClone)->
  arr = arrToClone.slice(0)
  i = 0
  while i < arrToClone.length
    arr[i] = _.deepClone arrToClone[i] if _.isArray arrToClone[i]
    i++
  arr

NAME            = "lucky7"  

REELS           = [
  ['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'b3', 'bt', 'bt', 'bt', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo']
  ['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'bt', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo']
  ['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'bt', 'bt', 'bt', 'bt', 'l7', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo']
]

NUMBER_OF_LINES = 1

MIN_CAP         = 100000000

MAX_CAP         = 100000000000

WIN_EDGE        = 0.004

class SlotMachine

  session: null

  constructor: (options = {})->
    @initSession(options)
    @unpack(options.session) if options.session

  initSession: (options)->
    @session =
      name: NAME
      currency: options.currency
      playerId: options.playerId
      playerUid: options.playerUid
      minCap: if options.minCap? then options.minCap else MIN_CAP
      maxCap: if options.maxCap? then options.maxCap else MAX_CAP
      linesCount: if options.linesCount? then options.linesCount else NUMBER_OF_LINES
      steps: []
      reels: []
      wager: null
      totalAmount: 0

  shuffleReels: ()->
    if @isLastStep undefined
      reels = []
      for reel in REELS
        reels.push _.shuffle reel
      @setReels reels
      @addStep "shuffle_reels"
      return @getReels()
    return false

  bet: (wager)->
    wager = parseInt wager
    if @isLastStep("shuffle_reels") and @isValidWager(wager)
      @session.wager = wager
      @addStep "bet_wager"
      return true
    false

  spin: ()->
    if @isLastStep "bet_wager"
      @addStep "spin"
      @chargeAmount -@getWager()
      payout = @getTotalReward()
      if payout > 0
        chargedAmount = @chargeAmount payout
      else
        chargedAmount = -@getWager()
      @addStep "game_over"
      return @getResult
        chargedAmount: chargedAmount
    return false

  getLuckyLines: ()->
    reels = @getReels()
    if reels.length
      luckyLines = []
      lineIndex = 0
      while lineIndex < @session.linesCount
        line = [reels[0][lineIndex], reels[1][lineIndex], reels[2][lineIndex]]
        luckyLines.push line if @getLineReward line
        lineIndex++
      return luckyLines
    null

  getLineReward: (line)->
    return AppHelper.multiplyBignums(@getWager(), 1)   if line[0] is "bw" and line[1] is "bw" and line[2] is "bw"
    return AppHelper.multiplyBignums(@getWager(), 500) if line[0] is "l7" and line[1] is "l7" and line[2] is "l7"
    return AppHelper.multiplyBignums(@getWager(), 100) if line[0] is "bt" and line[1] is "bt" and line[2] is "bt"
    return AppHelper.multiplyBignums(@getWager(), 30)  if line[0] is "b3" and line[1] is "b3" and line[2] is "b3"
    return AppHelper.multiplyBignums(@getWager(), 20)  if line[0] is "b2" and line[1] is "b2" and line[2] is "b2"
    return AppHelper.multiplyBignums(@getWager(), 10)  if line[0] is "b1" and line[1] is "b1" and line[2] is "b1"
    return AppHelper.multiplyBignums(@getWager(), 5)   if _.filter(line, (el)-> return el is "bt").length is 2
    return AppHelper.multiplyBignums(@getWager(), 2)   if "#{line[0]}#{line[1]}#{line[2]}".replace(/[1-3]/g, "") is "bbb"
    return AppHelper.multiplyBignums(@getWager(), 1)   if line.indexOf("bt") > -1
    return 0

  getTotalReward: ()->
    luckyLines = @getLuckyLines()
    reward = 0
    for line in luckyLines
      reward += @getLineReward(line)
    reward

  getAmount: ()->
    @session.totalAmount

  getWager: ()->
    @session.wager

  getNumberOfLines: ()->
    @session.linesCount

  getResult: (options)->
    result =
      reels: @getReels()
      result: @getLuckyLines()
      charged_amount: _s.satoshiRound options.chargedAmount

  getReels: ()->
    _.deepClone @session.reels

  setReels: (reels)->
    @session.reels = _.deepClone reels

  getWinEdge: ()->
    WIN_EDGE

  isValidWager: (wager)->
    _.isNumber(wager) and wager >= @session.minCap and wager <= @session.maxCap

  isOver: ()->
    @isLastStep "game_over"

  isWin: ()->
    @session.totalAmount >= 0

  isJackpot: ()->
    jackpot = ["bw", "bw", "bw"]
    for luckyLine in @getLuckyLines()
      return true if _.isEqual luckyLine, jackpot
    false

  chargeAmount: (amount)->
    amount = parseInt amount
    @session.totalAmount += amount
    @session.steps.push "add_amount_#{amount}"
    amount

  addStep: (step)->
    @session.steps.push step

  isLastStep: (step)->
    _.last(@session.steps) is step

  getName: ()->
    NAME

  getCurrency: ()->
    @session.currency

  getPlayerId: ()->
    @session.playerId

  getPlayerUid: ()->
    @session.playerUid

  pack: ()->
    JSON.stringify @session

  unpack: (session)->
    @session = JSON.parse session

exports = module.exports = SlotMachine