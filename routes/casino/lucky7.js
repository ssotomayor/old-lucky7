(function() {
  var AppHelper, JsonRenderer, ProvablyFairSlotMachine, SlotMachine, TempGame;

  SlotMachine = require("../../lib/casino/slot_machine");

  TempGame = require("../../models/temp_game");

  ProvablyFairSlotMachine = require("../../lib/provably_fair/provably_fair_slot_machine");

  AppHelper = require("../../lib/app_helper");

  JsonRenderer = require("../../lib/json_renderer");

  module.exports = function(app) {
    app.post("/lucky7/shuffle", function(req, res) {
      var response;
      response = {};
      return TempGame.findInProgress("lucky7", function(err, tempGame) {
        var game, hashSecret, provablyFair;
        if (tempGame == null) {
          tempGame = null;
        }
        if (err) {
          console.error(err);
        }
        game = null;
        if (tempGame) {
          game = new SlotMachine({
            session: tempGame.game_data
          });
        } else {
          game = new SlotMachine({
            maxCap: 10000000000000,
            minCap: 1,
            currency: "free",
            playerId: 1,
            playerUid: "123"
          });
          game.shuffleReels();
        }
        provablyFair = new ProvablyFairSlotMachine({
          collection: game.getReels()
        });
        hashSecret = provablyFair.hashSecret();
        response.hash_secret = hashSecret;
        return TempGame.store(tempGame, game, provablyFair.serverSeed, null, function(err) {
          if (err) {
            console.error(err);
          }
          return res.json(JsonRenderer.gameResponse(game, response));
        });
      });
    });
    return app.post("/lucky7/spin", function(req, res) {
      var clientSeed, response, wager;
      response = {};
      wager = AppHelper.balanceFromFloat(parseFloat(req.body.wager), "free");
      clientSeed = req.body.client_seed;
      return TempGame.findInProgress("lucky7", function(err, tempGame) {
        var diffBalance, finalShuffledReels, game, provablyFair, result;
        if (tempGame == null) {
          tempGame = null;
        }
        if (err) {
          console.error(err);
        }
        if (!tempGame) {
          return JsonRenderer.error("There is no started game.", res);
        }
        game = new SlotMachine({
          session: tempGame.game_data
        });
        provablyFair = new ProvablyFairSlotMachine({
          collection: game.getReels(),
          serverSeed: tempGame.server_seed,
          clientSeed: clientSeed
        });
        finalShuffledReels = provablyFair.finalShuffle();
        game.setReels(finalShuffledReels);
        if (!game.bet(wager)) {
          return JsonRenderer.error("You can not bet. The wager must be between the specified boundaries.", res);
        }
        result = game.spin();
        if (!result) {
          return JsonRenderer.error("You can not spin.", res);
        }
        if (!game.isOver()) {
          return JsonRenderer.error("Game error...your funds are safe.", res);
        }
        response = result;
        diffBalance = game.getAmount();
        response.balance = 100000000000;
        response.provably_fair = provablyFair.result();
        response.provably_fair.game_type = "lucky7";
        return TempGame.purge(tempGame, game, function(err) {
          if (err) {
            console.error(err);
          }
          return res.json(JsonRenderer.gameResponse(game, response));
        });
      });
    });
  };

}).call(this);
