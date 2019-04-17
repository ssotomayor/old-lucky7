simpleCdn   = require "express-simple-cdn"
environment = process.env.NODE_ENV or 'development'

initAssets = (app)->
  connectAssetsOptions =
    production:
      helperContext: app.locals
      servePath:     "#{GLOBAL.appConfig().assets_host or ''}/assets"
      build:         true
      buildDir:      "builtAssets"
      compile:       true
      compress:      true
      flush:         true
    development:
      precompile: ["null"]
  app.locals.AppHelper      = require("./app_helper")
  app.locals._              = require("underscore")
  app.locals._str           = require("./underscore_string")
  app.locals.math           = require("./math")
  app.locals.CDN            = (path, noKey)->
    glueSign  = if path.indexOf("?") > -1 then "&" else "?"
    assetsKey = if not noKey and GLOBAL.appConfig().assets_key then "#{glueSign}_=#{GLOBAL.appConfig().assets_key}" else ""
    simpleCdn(path, GLOBAL.appConfig().assets_host) + assetsKey;
  connectAssets        = require('connect-assets')(connectAssetsOptions[environment])
exports = module.exports = initAssets