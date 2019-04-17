_    = require "underscore"
math = require "./math"

GAME_NAMES                      = [
  "lucky7"
]

GAME_FULL_NAMES                 =
  "lucky7": "Lucky 7"

GAME_NAMES_INTS                 =
  lucky7:            2

CURRENCIES                      = [
  "free"
]

CURRENCIES_NON_FREE             = [
  "free"
]

CURRENCY_SYMBOLS                =
  "free": "Play Money"

CURRENCY_INTS                   =
  free: 1

CURRENCY_NAMES                  =
  "free": "play money"

AppHelper =

  getCurrencies: (nonFree = false)->
    return CURRENCIES_NON_FREE  if nonFree
    CURRENCIES

  getCurrencyName: (currency)->
    CURRENCY_NAMES[currency]

  getCurrencyNames: (asString = false)->
    return JSON.stringify CURRENCY_NAMES  if asString
    CURRENCY_NAMES

  getCurrencyInt: (currencyLiteral)->
    CURRENCY_INTS[currencyLiteral]

  getCurrencyLiteral: (currencyInt)->
    literal = _.invert(CURRENCY_INTS)[currencyInt]
    return "Unknown"  if not literal
    literal

  isValidCurrency: (currency)->
    CURRENCIES.indexOf(currency) > -1

  getCurrencySymbol: (currency)->
    return CURRENCY_SYMBOLS[currency]  if CURRENCY_SYMBOLS[currency]?
    return "Unknown"  if not currency
    currency.toUpperCase()

  getGameNames: ()->
    GAME_NAMES

  getGameFullName: (name)->
    GAME_FULL_NAMES[name]

  getGameNameLiteral: (nameInt)->
    _.invert(GAME_NAMES_INTS)[nameInt]

  getGameNameInt: (name)->
    GAME_NAMES_INTS[name]

  toBignum: (value)->
    math.bignumber "#{value}"
  
  toBigint: (value)->
    parseInt math.multiply(@toBignum(value), @toBignum(100000000))

  fromBigint: (value)->
    parseFloat math.divide(@toBignum(value), @toBignum(100000000))

  multiplyBignums: (num1, num2)->
    parseInt math.multiply(@toBignum(num1), @toBignum(num2))

  divideBignums: (num1, num2)->
    parseInt math.divide(@toBignum(num1), @toBignum(num2))

  subtractBignums: (num1, num2)->
    parseInt math.subtract(@toBignum(num1), @toBignum(num2))

  addBignums: (num1, num2)->
    parseInt math.add(@toBignum(num1), @toBignum(num2))

  renderBalance: (bigintBalance, type)->
    bigintBalance
  
  renderFloatBalance: (bigintBalance, type)->
    @fromBigint bigintBalance

  balanceFromBigint: (bigintBalance, type)->
    bigintBalance

  balanceFromFloat: (floatBalance, type)->
    @toBigint floatBalance

exports = module.exports = AppHelper