(function() {
  var ProvablyFair, ProvablyFairSlotMachine, exports, mersenne,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  mersenne = require("mersenne");

  ProvablyFair = require("./provably_fair");

  ProvablyFairSlotMachine = (function(_super) {
    __extends(ProvablyFairSlotMachine, _super);

    function ProvablyFairSlotMachine() {
      return ProvablyFairSlotMachine.__super__.constructor.apply(this, arguments);
    }

    ProvablyFairSlotMachine.prototype.stringifyCollection = function(collection) {
      var item, reel, stringifiedCollection, _i, _j, _len, _len1;
      stringifiedCollection = "";
      for (_i = 0, _len = collection.length; _i < _len; _i++) {
        reel = collection[_i];
        for (_j = 0, _len1 = reel.length; _j < _len1; _j++) {
          item = reel[_j];
          stringifiedCollection += "" + item + "|";
        }
        stringifiedCollection = stringifiedCollection.substr(0, stringifiedCollection.length - 1);
        stringifiedCollection += "-";
      }
      return stringifiedCollection.substr(0, stringifiedCollection.length - 1);
    };

    ProvablyFairSlotMachine.prototype.finalShuffle = function() {
      var mt, reel, seed, _i, _len, _ref;
      seed = this.hash("" + this.clientSeed + this.serverSeed);
      seed = parseInt(seed.substring(seed.length - 8), 16);
      mt = new mersenne.MersenneTwister19937();
      mt.init_genrand(seed);
      this.finalShuffled = [];
      _ref = this.collection;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        reel = _ref[_i];
        this.finalShuffled.push(this.fisherYatesShuffle(reel, mt));
      }
      return this.finalShuffled;
    };

    return ProvablyFairSlotMachine;

  })(ProvablyFair);

  exports = module.exports = ProvablyFairSlotMachine;

}).call(this);
