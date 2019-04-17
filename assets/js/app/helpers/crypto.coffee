window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.Crypto = window.App.Helpers.Crypto or {}

App.Helpers.Crypto =

  CURRENCY_SYMBOLS:
    "btc": "m฿", "free": "Play Money"

  # TODO move to separate helper
  GAME_FULL_NAMES:
    "casino_war": "Casino War", "lucky7": "Lucky 7", "roulette": "Roulette", "blackjack": "Blackjack", 
    "video_poker": "Video Poker", "baccarat": "Baccarat", "dice": "Dice", "bombs": "Minesweeper", "american_roulette": "American Roulette"

  getGameFullName: (name)->
    @GAME_FULL_NAMES[name]

  getCurrencySymbol: (currency)->
    return @CURRENCY_SYMBOLS[currency]  if @CURRENCY_SYMBOLS[currency]?
    return "Unknown"  if not currency
    currency.toUpperCase()

  getCurrencyName: (currency)->
    CONFIG.currencyNames[currency]

  getCryptoAddressUrl: (currency, address)->
    return "https://blockchain.info/address/#{address}"  if currency is "btc"
    "http://bitinfocharts.com/#{@getCurrencyName(currency)}/address/#{address}"

  getCryptoTxUrl: (currency, txid)->
    return "https://blockchain.info/tx/#{txid}"  if currency is "btc"
    "http://bitinfocharts.com/#{@getCurrencyName(currency)}/tx/#{txid}"
