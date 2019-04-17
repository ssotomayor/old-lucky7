window.App or= {}

class window.App.GameStatsView

  el: null

  $totalGamesCnt: null
  
  $totalWinAmountCnt: null
  
  $jackpotAmountCnt: null

  constructor: (options = {})->
    @el = options.el or $("body")
    @$totalGamesCnt = $(@el).find("#total-games")
    @$totalWinAmountCnt = $(@el).find("#total-win-amount")
    @$jackpotAmountCnt = $(@el).find("#jackpot-amount")

  updateStats: (stats)=>
    balanceType = CONFIG.balanceType
    balanceType = "btc"  if CONFIG.balanceType is "free"
    if balanceType is stats.currency
      currencySymbol = CONFIG.currencySymbol
      currencySymbol = "m฿"  if CONFIG.balanceType is "free"
      @$totalGamesCnt.text _.str.numberFormat(stats.total_games)  if @$totalGamesCnt.length
      @$totalWinAmountCnt.text _.str.numberFormat(stats.total_win) + " " + currencySymbol  if @$totalWinAmountCnt.length
      @$jackpotAmountCnt.text _.str.numberFormat(stats.lucky7_jackpot) + " " + currencySymbol  if @$jackpotAmountCnt.length

  render: ()->
    if @$totalGamesCnt.length or @$totalWinAmountCnt.length or @$jackpotAmountCnt.length
      balanceType = CONFIG.balanceType
      balanceType = "btc"  if CONFIG.balanceType is "free"
      $.getJSON "/games_stats/#{balanceType}", @updateStats
      @socket = io.connect("#{CONFIG.players.hostname}/game_stats")
      @socket.on "stats-change", @updateStats