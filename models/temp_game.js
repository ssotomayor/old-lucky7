(function() {
  var AppHelper, TempGame, TempGameSchema, exports;

  AppHelper = require("../lib/app_helper");

  TempGameSchema = new Schema({
    player_id: {
      type: String,
      index: true
    },
    currency: {
      type: String,
      "enum": AppHelper.getCurrencies(),
      "default": "free"
    },
    name: {
      type: String,
      "enum": AppHelper.getGameNames()
    },
    is_over: {
      type: Boolean,
      "default": false,
      index: true
    },
    game_data: {
      type: String
    },
    server_seed: {
      type: String
    },
    provably_fair_result: {
      type: {}
    },
    created: {
      type: Date,
      "default": Date.now,
      index: true
    }
  });

  TempGameSchema.set("autoIndex", false);

  TempGameSchema.statics.store = function(tempGame, game, serverSeed, provablyFairResult, callback) {
    if (callback == null) {
      callback = function() {};
    }
    if (!tempGame) {
      tempGame = new TempGame;
    }
    tempGame.player_id = game.getPlayerId();
    tempGame.currency = game.getCurrency();
    tempGame.name = game.getName();
    tempGame.is_over = game.isOver();
    tempGame.game_data = game.pack();
    if (serverSeed) {
      tempGame.server_seed = serverSeed;
    }
    if (provablyFairResult) {
      tempGame.provably_fair_result = provablyFairResult;
    }
    return tempGame.save(callback);
  };

  TempGameSchema.statics.findInProgress = function(name, callback) {
    if (callback == null) {
      callback = function() {};
    }
    return TempGame.findOne({
      player_id: 1,
      currency: "free",
      name: name,
      is_over: false
    }, callback);
  };

  TempGameSchema.statics.purge = function(tempGame, game, callback) {
    if (callback == null) {
      callback = function() {};
    }
    return TempGame.store(tempGame, game, null, null, callback);
  };

  TempGame = mongoose.model("TempGame", TempGameSchema);

  exports = module.exports = TempGame;

}).call(this);
