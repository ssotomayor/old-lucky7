(function() {
  var AppHelper, CURRENCIES, CURRENCIES_NON_FREE, CURRENCY_INTS, CURRENCY_NAMES, CURRENCY_SYMBOLS, GAME_FULL_NAMES, GAME_NAMES, GAME_NAMES_INTS, exports, math, _;

  _ = require("underscore");

  math = require("./math");

  GAME_NAMES = ["lucky7"];

  GAME_FULL_NAMES = {
    "lucky7": "Lucky 7"
  };

  GAME_NAMES_INTS = {
    lucky7: 2
  };

  CURRENCIES = ["free"];

  CURRENCIES_NON_FREE = ["free"];

  CURRENCY_SYMBOLS = {
    "free": "Play Money"
  };

  CURRENCY_INTS = {
    free: 1
  };

  CURRENCY_NAMES = {
    "free": "play money"
  };

  AppHelper = {
    getCurrencies: function(nonFree) {
      if (nonFree == null) {
        nonFree = false;
      }
      if (nonFree) {
        return CURRENCIES_NON_FREE;
      }
      return CURRENCIES;
    },
    getCurrencyName: function(currency) {
      return CURRENCY_NAMES[currency];
    },
    getCurrencyNames: function(asString) {
      if (asString == null) {
        asString = false;
      }
      if (asString) {
        return JSON.stringify(CURRENCY_NAMES);
      }
      return CURRENCY_NAMES;
    },
    getCurrencyInt: function(currencyLiteral) {
      return CURRENCY_INTS[currencyLiteral];
    },
    getCurrencyLiteral: function(currencyInt) {
      var literal;
      literal = _.invert(CURRENCY_INTS)[currencyInt];
      if (!literal) {
        return "Unknown";
      }
      return literal;
    },
    isValidCurrency: function(currency) {
      return CURRENCIES.indexOf(currency) > -1;
    },
    getCurrencySymbol: function(currency) {
      if (CURRENCY_SYMBOLS[currency] != null) {
        return CURRENCY_SYMBOLS[currency];
      }
      if (!currency) {
        return "Unknown";
      }
      return currency.toUpperCase();
    },
    getGameNames: function() {
      return GAME_NAMES;
    },
    getGameFullName: function(name) {
      return GAME_FULL_NAMES[name];
    },
    getGameNameLiteral: function(nameInt) {
      return _.invert(GAME_NAMES_INTS)[nameInt];
    },
    getGameNameInt: function(name) {
      return GAME_NAMES_INTS[name];
    },
    toBignum: function(value) {
      return math.bignumber("" + value);
    },
    toBigint: function(value) {
      return parseInt(math.multiply(this.toBignum(value), this.toBignum(100000000)));
    },
    fromBigint: function(value) {
      return parseFloat(math.divide(this.toBignum(value), this.toBignum(100000000)));
    },
    multiplyBignums: function(num1, num2) {
      return parseInt(math.multiply(this.toBignum(num1), this.toBignum(num2)));
    },
    divideBignums: function(num1, num2) {
      return parseInt(math.divide(this.toBignum(num1), this.toBignum(num2)));
    },
    subtractBignums: function(num1, num2) {
      return parseInt(math.subtract(this.toBignum(num1), this.toBignum(num2)));
    },
    addBignums: function(num1, num2) {
      return parseInt(math.add(this.toBignum(num1), this.toBignum(num2)));
    },
    renderBalance: function(bigintBalance, type) {
      return bigintBalance;
    },
    renderFloatBalance: function(bigintBalance, type) {
      return this.fromBigint(bigintBalance);
    },
    balanceFromBigint: function(bigintBalance, type) {
      return bigintBalance;
    },
    balanceFromFloat: function(floatBalance, type) {
      return this.toBigint(floatBalance);
    }
  };

  exports = module.exports = AppHelper;

}).call(this);
