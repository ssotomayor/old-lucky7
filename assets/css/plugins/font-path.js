var appConfig = function () {
  if (!GLOBAL.appConfig) GLOBAL.appConfig = require(process.cwd() + "/config/config");
  return GLOBAL.appConfig;
};

var plugin = function(){
  return function(style){
    style.define("font-path", function(fontOptions) {
      var host = appConfig().fonts_host || "";
      return host + fontOptions.string;
    });
  };
};

module.exports = plugin;