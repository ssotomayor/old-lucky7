window.App or= {}

class App.PlayerModel extends Backbone.Model

  urlRoot: "/player.json"

  lastError: null

  reactOnBalanceChange: true

  load: (callback)->
    @fetch
      success: ()->
        callback() if callback

  openUpdateSocket: ()->
    @load ()=>
      if @id and window.io
        @socket = io.connect("#{CONFIG.players.hostname}/players")
        @socket.on "connect", ()=>
        @socket.on "new-wallet-balance", (data)=>
          $.publish "new-wallet-balance", data.amount  if data.balance_type is @get("selected_balance_type")
        @socket.on "balance-change", (data)=>
          @setBalance data.balance  if @reactOnBalanceChange and data.balance_type is @get("selected_balance_type")
        @socket.on "payment-processed", (data)=>
          $.publish "payment-processed", data  if data.balance_type is @get("selected_balance_type")

  setBalance: (balance, inSync = true)->
    @set "balance", balance
    $.publish "player-balance", [balance, inSync]

  isValidBet: (wager, betOnTie = false)->
    if wager < CONFIG.minCap or wager > CONFIG.maxCap
      @lastError = "You can not bet. The wager must be between the specified boundaries."
      return false
    canPlayAmount = wager
    canPlayAmount += wager if betOnTie
    if canPlayAmount > @get("balance")
      @lastError = "You can not bet.  You have insufficient funds. Please deposit."
      return false
    return true

  isValidBetNoMaxCap: (wager)->
    if wager < CONFIG.minCap
      @lastError = "You can not bet. The wager must be between the specified boundaries."
      return false
    if wager > @get("balance")
      @lastError = "You can not bet.  You have insufficient funds. Please deposit."
      return false
    return true 

  getLastError: ()->
    responseText: @lastError
