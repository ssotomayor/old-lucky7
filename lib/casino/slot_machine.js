(function() {
  var AppHelper, MAX_CAP, MIN_CAP, NAME, NUMBER_OF_LINES, REELS, SlotMachine, WIN_EDGE, exports, _, _s;

  _ = require("underscore");

  _s = require("../underscore_string");

  AppHelper = require("../app_helper");

  _.deepClone = function(arrToClone) {
    var arr, i;
    arr = arrToClone.slice(0);
    i = 0;
    while (i < arrToClone.length) {
      if (_.isArray(arrToClone[i])) {
        arr[i] = _.deepClone(arrToClone[i]);
      }
      i++;
    }
    return arr;
  };

  NAME = "lucky7";

  REELS = [['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'b3', 'bt', 'bt', 'bt', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo'], ['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'bt', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo'], ['bw', 'b1', 'b1', 'b1', 'b1', 'b1', 'b1', 'b2', 'b2', 'b2', 'b2', 'b2', 'b3', 'b3', 'b3', 'b3', 'bt', 'bt', 'bt', 'bt', 'l7', 'l7', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo', 'zo']];

  NUMBER_OF_LINES = 1;

  MIN_CAP = 100000000;

  MAX_CAP = 100000000000;

  WIN_EDGE = 0.004;

  SlotMachine = (function() {
    SlotMachine.prototype.session = null;

    function SlotMachine(options) {
      if (options == null) {
        options = {};
      }
      this.initSession(options);
      if (options.session) {
        this.unpack(options.session);
      }
    }

    SlotMachine.prototype.initSession = function(options) {
      return this.session = {
        name: NAME,
        currency: options.currency,
        playerId: options.playerId,
        playerUid: options.playerUid,
        minCap: options.minCap != null ? options.minCap : MIN_CAP,
        maxCap: options.maxCap != null ? options.maxCap : MAX_CAP,
        linesCount: options.linesCount != null ? options.linesCount : NUMBER_OF_LINES,
        steps: [],
        reels: [],
        wager: null,
        totalAmount: 0
      };
    };

    SlotMachine.prototype.shuffleReels = function() {
      var reel, reels, _i, _len;
      if (this.isLastStep(void 0)) {
        reels = [];
        for (_i = 0, _len = REELS.length; _i < _len; _i++) {
          reel = REELS[_i];
          reels.push(_.shuffle(reel));
        }
        this.setReels(reels);
        this.addStep("shuffle_reels");
        return this.getReels();
      }
      return false;
    };

    SlotMachine.prototype.bet = function(wager) {
      wager = parseInt(wager);
      if (this.isLastStep("shuffle_reels") && this.isValidWager(wager)) {
        this.session.wager = wager;
        this.addStep("bet_wager");
        return true;
      }
      return false;
    };

    SlotMachine.prototype.spin = function() {
      var chargedAmount, payout;
      if (this.isLastStep("bet_wager")) {
        this.addStep("spin");
        this.chargeAmount(-this.getWager());
        payout = this.getTotalReward();
        if (payout > 0) {
          chargedAmount = this.chargeAmount(payout);
        } else {
          chargedAmount = -this.getWager();
        }
        this.addStep("game_over");
        return this.getResult({
          chargedAmount: chargedAmount
        });
      }
      return false;
    };

    SlotMachine.prototype.getLuckyLines = function() {
      var line, lineIndex, luckyLines, reels;
      reels = this.getReels();
      if (reels.length) {
        luckyLines = [];
        lineIndex = 0;
        while (lineIndex < this.session.linesCount) {
          line = [reels[0][lineIndex], reels[1][lineIndex], reels[2][lineIndex]];
          if (this.getLineReward(line)) {
            luckyLines.push(line);
          }
          lineIndex++;
        }
        return luckyLines;
      }
      return null;
    };

    SlotMachine.prototype.getLineReward = function(line) {
      if (line[0] === "bw" && line[1] === "bw" && line[2] === "bw") {
        return AppHelper.multiplyBignums(this.getWager(), 1);
      }
      if (line[0] === "l7" && line[1] === "l7" && line[2] === "l7") {
        return AppHelper.multiplyBignums(this.getWager(), 500);
      }
      if (line[0] === "bt" && line[1] === "bt" && line[2] === "bt") {
        return AppHelper.multiplyBignums(this.getWager(), 100);
      }
      if (line[0] === "b3" && line[1] === "b3" && line[2] === "b3") {
        return AppHelper.multiplyBignums(this.getWager(), 30);
      }
      if (line[0] === "b2" && line[1] === "b2" && line[2] === "b2") {
        return AppHelper.multiplyBignums(this.getWager(), 20);
      }
      if (line[0] === "b1" && line[1] === "b1" && line[2] === "b1") {
        return AppHelper.multiplyBignums(this.getWager(), 10);
      }
      if (_.filter(line, function(el) {
        return el === "bt";
      }).length === 2) {
        return AppHelper.multiplyBignums(this.getWager(), 5);
      }
      if (("" + line[0] + line[1] + line[2]).replace(/[1-3]/g, "") === "bbb") {
        return AppHelper.multiplyBignums(this.getWager(), 2);
      }
      if (line.indexOf("bt") > -1) {
        return AppHelper.multiplyBignums(this.getWager(), 1);
      }
      return 0;
    };

    SlotMachine.prototype.getTotalReward = function() {
      var line, luckyLines, reward, _i, _len;
      luckyLines = this.getLuckyLines();
      reward = 0;
      for (_i = 0, _len = luckyLines.length; _i < _len; _i++) {
        line = luckyLines[_i];
        reward += this.getLineReward(line);
      }
      return reward;
    };

    SlotMachine.prototype.getAmount = function() {
      return this.session.totalAmount;
    };

    SlotMachine.prototype.getWager = function() {
      return this.session.wager;
    };

    SlotMachine.prototype.getNumberOfLines = function() {
      return this.session.linesCount;
    };

    SlotMachine.prototype.getResult = function(options) {
      var result;
      return result = {
        reels: this.getReels(),
        result: this.getLuckyLines(),
        charged_amount: _s.satoshiRound(options.chargedAmount)
      };
    };

    SlotMachine.prototype.getReels = function() {
      return _.deepClone(this.session.reels);
    };

    SlotMachine.prototype.setReels = function(reels) {
      return this.session.reels = _.deepClone(reels);
    };

    SlotMachine.prototype.getWinEdge = function() {
      return WIN_EDGE;
    };

    SlotMachine.prototype.isValidWager = function(wager) {
      return _.isNumber(wager) && wager >= this.session.minCap && wager <= this.session.maxCap;
    };

    SlotMachine.prototype.isOver = function() {
      return this.isLastStep("game_over");
    };

    SlotMachine.prototype.isWin = function() {
      return this.session.totalAmount >= 0;
    };

    SlotMachine.prototype.isJackpot = function() {
      var jackpot, luckyLine, _i, _len, _ref;
      jackpot = ["bw", "bw", "bw"];
      _ref = this.getLuckyLines();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        luckyLine = _ref[_i];
        if (_.isEqual(luckyLine, jackpot)) {
          return true;
        }
      }
      return false;
    };

    SlotMachine.prototype.chargeAmount = function(amount) {
      amount = parseInt(amount);
      this.session.totalAmount += amount;
      this.session.steps.push("add_amount_" + amount);
      return amount;
    };

    SlotMachine.prototype.addStep = function(step) {
      return this.session.steps.push(step);
    };

    SlotMachine.prototype.isLastStep = function(step) {
      return _.last(this.session.steps) === step;
    };

    SlotMachine.prototype.getName = function() {
      return NAME;
    };

    SlotMachine.prototype.getCurrency = function() {
      return this.session.currency;
    };

    SlotMachine.prototype.getPlayerId = function() {
      return this.session.playerId;
    };

    SlotMachine.prototype.getPlayerUid = function() {
      return this.session.playerUid;
    };

    SlotMachine.prototype.pack = function() {
      return JSON.stringify(this.session);
    };

    SlotMachine.prototype.unpack = function(session) {
      return this.session = JSON.parse(session);
    };

    return SlotMachine;

  })();

  exports = module.exports = SlotMachine;

}).call(this);
