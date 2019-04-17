var appConfig = function () {
  if (!GLOBAL.appConfig) GLOBAL.appConfig = require(process.cwd() + "/config/config");
  return GLOBAL.appConfig;
};

var plugin = function(){
  return function(style){
    style.define("CDN", function(imgOptions) {
      var host = appConfig().assets_host || "";
      var glueSign = imgOptions.string.indexOf("?") > -1 ? "&" : "?";
      var key = appConfig().assets_key ? glueSign + "_=" + appConfig().assets_key : "";
      return host + imgOptions.string + key;
    });
  };
};

module.exports = plugin;