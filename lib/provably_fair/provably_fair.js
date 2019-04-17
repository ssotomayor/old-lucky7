(function() {
  var ProvablyFair, crypto, exports, mersenne;

  crypto = require("crypto");

  mersenne = require("mersenne");

  ProvablyFair = (function() {
    ProvablyFair.prototype.collection = null;

    ProvablyFair.prototype.initialShuffle = null;

    ProvablyFair.prototype.serverSeed = null;

    ProvablyFair.prototype.clientSeed = null;

    ProvablyFair.prototype.finalShuffle = null;

    function ProvablyFair(options) {
      if (options == null) {
        options = {};
      }
      this.collection = options.collection;
      if (this.collection) {
        this.initialShuffle = this.stringifyCollection(this.collection);
      }
      this.serverSeed = options.serverSeed;
      this.clientSeed = options.clientSeed;
    }

    ProvablyFair.prototype.stringifyCollection = function() {};

    ProvablyFair.prototype.hash = function(value) {
      return crypto.createHash("sha256").update("" + value, "utf8").digest("hex");
    };

    ProvablyFair.prototype.random = function() {
      return this.hash(Math.random());
    };

    ProvablyFair.prototype.hashSecret = function() {
      this.serverSeed = this.serverSeed || this.random();
      return this.hash("" + this.serverSeed + this.initialShuffle);
    };

    ProvablyFair.prototype.finalShuffle = function() {
      var mt, seed;
      seed = this.hash("" + this.clientSeed + this.serverSeed);
      seed = parseInt(seed.substring(seed.length - 8), 16);
      mt = new mersenne.MersenneTwister19937();
      mt.init_genrand(seed);
      return this.finalShuffled = this.fisherYatesShuffle(this.collection, mt);
    };

    ProvablyFair.prototype.fisherYatesShuffle = function(collection, twister) {
      var i, r, tmp;
      tmp = void 0;
      i = collection.length - 1;
      while (i > 0) {
        r = twister.genrand_int32() % (i + 1);
        tmp = collection[r];
        collection[r] = collection[i];
        collection[i] = tmp;
        i--;
      }
      return collection;
    };

    ProvablyFair.prototype.result = function() {
      return {
        client_seed: this.clientSeed,
        hash_secret: this.hashSecret(),
        server_seed: this.serverSeed,
        initial_shuffle: this.initialShuffle,
        final_shuffle: this.stringifyCollection(this.finalShuffled)
      };
    };

    return ProvablyFair;

  })();

  exports = module.exports = ProvablyFair;

}).call(this);
