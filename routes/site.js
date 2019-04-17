(function() {
  var JsonRenderer, querystring, _, _str;

  JsonRenderer = require("../lib/json_renderer");

  _ = require("underscore");

  _str = require("../lib/underscore_string");

  querystring = require("querystring");

  module.exports = function(app) {
    var render;
    render = function(res, tpl, titlePrefix, description, playGame, gameData) {
      if (description == null) {
        description = null;
      }
      if (playGame == null) {
        playGame = null;
      }
      if (gameData == null) {
        gameData = null;
      }
      return res.render("site/" + tpl, {
        title: "" + titlePrefix + " - Satoshibet",
        description: description,
        playGame: playGame,
        gameData: gameData,
        jackpotMinCap: 1,
        _str: _str
      });
    };
    app.get("/", function(req, res) {
      return res.redirect("/lucky7");
    });
    app.get("/lucky7", function(req, res) {
      var description, playGame, slug, title;
      slug = req.query.player;
      title = res.__("Bitcoin Circle Machine Lucky");
      description = res.__("Bitcoin Circle Machine. Play Roulette machine and win the Progressive Jackpot. No registration. Provably Fair.");
      playGame = "lucky7";
      req.session.playGame = playGame;
      return render(res, "casino_game", title, description, playGame);
    });
    return app.get("/player.json/:uid?", function(req, res) {
      var playerJson;
      playerJson = {
        type: "free",
        username: "test",
        email: "test",
        address: "test",
        balance: "free",
        slug: "",
        selected_balance_type: "free",
        id: "123"
      };
      return res.json(playerJson);
    });
  };

}).call(this);
