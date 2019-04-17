(function() {
  var AppHelper, JsonRenderer, SlotMachine, exports, _, _str;

  SlotMachine = require("./casino/slot_machine");

  AppHelper = require("./app_helper");

  _ = require("underscore");

  _str = require("./underscore_string");

  JsonRenderer = {
    gameResponse: function(game, response) {
      var gameStateKeys, key, keysToConvert, _i, _j, _len, _len1;
      keysToConvert = ["amount", "balance", "won_amount", "lost_amount", "charged_amount", "charged_tie_amount", "tie_bet", "surrender_tax", "war_tax", "profit", "wager"];
      for (_i = 0, _len = keysToConvert.length; _i < _len; _i++) {
        key = keysToConvert[_i];
        if (response[key] != null) {
          response[key] = AppHelper.renderFloatBalance(response[key], game.getCurrency());
        }
      }
      gameStateKeys = ["wager", "war_tax", "surrender_tax", "tie_bet", "charged_tie_amount", "charged_amount"];
      if (response.game_state) {
        for (_j = 0, _len1 = gameStateKeys.length; _j < _len1; _j++) {
          key = gameStateKeys[_j];
          if (response.game_state[key] != null) {
            response.game_state[key] = AppHelper.renderFloatBalance(response.game_state[key], game.getCurrency());
          }
        }
      }
      return response;
    },
    player: function(player, options) {
      var playerJson;
      if (options == null) {
        options = {
          withId: true
        };
      }
      playerJson = {
        type: player.type,
        username: player.username,
        email: player.email,
        address: player.getAddress(),
        balance: AppHelper.renderFloatBalance(player.getBalance(), player.getBalanceType()),
        slug: player.slug,
        selected_balance_type: player.getBalanceType()
      };
      if (options.withId) {
        playerJson.id = player.uid;
      }
      return playerJson;
    },
    error: function(err, res, code, log) {
      var key, message, val, _ref;
      if (code == null) {
        code = 409;
      }
      if (log == null) {
        log = false;
      }
      res.statusCode = code;
      message = "";
      if (_.isString(err)) {
        message = err;
      } else if (_.isObject(err) && err.name === "ValidationError") {
        _ref = err.errors;
        for (key in _ref) {
          val = _ref[key];
          if (val.path === "email" && val.message === "unique") {
            message += "E-mail is already taken. ";
          } else {
            message += "" + val.message + " ";
          }
        }
      }
      if (res.__) {
        message = res.__(message);
      }
      res.json({
        error: message
      });
      if (log) {
        return console.error(message);
      }
    },
    sqlError: function(err, res, code, log) {
      var key, message, val;
      if (code == null) {
        code = 409;
      }
      if (log == null) {
        log = true;
      }
      if (log) {
        console.error(err);
      }
      if (res) {
        res.statusCode = code;
      }
      if (_.isObject(err)) {
        delete err.sql;
        if (res && err.code === "ER_DUP_ENTRY") {
          return res.json({
            error: this.formatError("" + err)
          });
        }
      }
      message = "";
      if (_.isString(err)) {
        message = err;
      } else if (_.isObject(err)) {
        for (key in err) {
          val = err[key];
          if (_.isArray(val)) {
            message += "" + (val.join(' ')) + " ";
          } else {
            message += "" + val + " ";
          }
        }
      }
      if (res) {
        return res.json({
          error: this.formatError(message)
        });
      }
      return this.formatError(message);
    },
    formatError: function(message) {
      message = message.replace("Error: ER_DUP_ENTRY: ", "");
      message = message.replace(/for key.*$/, "");
      message = message.replace(/Duplicate entry/, "Value already taken");
      message = message.replace("ConflictError ", "");
      return _str.trim(message);
    }
  };

  exports = module.exports = JsonRenderer;

}).call(this);
