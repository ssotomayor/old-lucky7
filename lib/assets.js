(function() {
  var environment, exports, initAssets, simpleCdn;

  simpleCdn = require("express-simple-cdn");

  environment = process.env.NODE_ENV || 'development';

  initAssets = function(app) {
    var connectAssets, connectAssetsOptions;
    connectAssetsOptions = {
      production: {
        helperContext: app.locals,
        servePath: "" + (GLOBAL.appConfig().assets_host || '') + "/assets",
        build: true,
        buildDir: "builtAssets",
        compile: true,
        compress: true,
        flush: true
      },
      development: {
        precompile: ["null"]
      }
    };
    app.locals.AppHelper = require("./app_helper");
    app.locals._ = require("underscore");
    app.locals._str = require("./underscore_string");
    app.locals.math = require("./math");
    app.locals.CDN = function(path, noKey) {
      var assetsKey, glueSign;
      glueSign = path.indexOf("?") > -1 ? "&" : "?";
      assetsKey = !noKey && GLOBAL.appConfig().assets_key ? "" + glueSign + "_=" + (GLOBAL.appConfig().assets_key) : "";
      return simpleCdn(path, GLOBAL.appConfig().assets_host) + assetsKey;
    };
    return connectAssets = require('connect-assets')(connectAssetsOptions[environment]);
  };

  exports = module.exports = initAssets;

}).call(this);
