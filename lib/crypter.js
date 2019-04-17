(function() {
  var Crypter, crypto, exports;

  crypto = require("crypto");

  Crypter = (function() {
    Crypter.prototype.configPath = "config.json";

    Crypter.prototype.algorithm = null;

    Crypter.prototype.key = null;

    function Crypter(options) {
      if (options && options.configPath) {
        this.configPath = options.configPath;
      }
      if (!options) {
        options = this.loadOptionsFromFile();
      }
      this.setupOptions(options);
    }

    Crypter.prototype.setupOptions = function(options) {
      this.algorithm = options.algorithm;
      return this.key = options.key;
    };

    Crypter.prototype.encode = function(value) {
      var cipher, enc;
      cipher = crypto.createCipher(this.algorithm, this.key);
      enc = cipher.update(value, "utf8", "hex");
      return enc += cipher.final("hex");
    };

    Crypter.prototype.decode = function(value) {
      var decipher, enc;
      decipher = crypto.createDecipher(this.algorithm, this.key);
      enc = decipher.update(value, "hex", "utf8");
      return enc += decipher.final("utf8");
    };

    Crypter.prototype.md5 = function(value) {
      return crypto.createHash("md5").update("" + value + this.key, "utf8").digest("hex");
    };

    Crypter.prototype.loadOptionsFromFile = function() {
      var environment, fs, options;
      options = GLOBAL.appConfig();
      if (!options) {
        fs = require("fs");
        environment = process.env.NODE_ENV || "development";
        options = JSON.parse(fs.readFileSync("" + (process.cwd()) + "/" + this.configPath, "utf8"))[environment];
      }
      return options.crypter;
    };

    return Crypter;

  })();

  exports = module.exports = Crypter;

}).call(this);
