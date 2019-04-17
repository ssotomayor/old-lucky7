(function() {
  var capsConfigPath, config, environment, exports, fs;

  fs = require("fs");

  environment = process.env.NODE_ENV || "development";

  capsConfigPath = __dirname + "/caps_config";

  config = JSON.parse(fs.readFileSync(process.cwd() + "/config.json", "utf8"))[environment];

  fs.readdirSync(capsConfigPath).filter(function(file) {
    return /.json$/.test(file);
  }).forEach(function(file) {
    var cap, currency;
    currency = file.replace(".json", "");
    cap = JSON.parse(fs.readFileSync("" + capsConfigPath + "/" + file));
    config.caps.min[currency] = cap.min;
    config.caps.max[currency] = cap.max;
  });

  exports = module.exports = function() {
    return config;
  };

}).call(this);
