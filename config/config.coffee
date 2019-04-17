fs                = require "fs"
environment       = process.env.NODE_ENV or "development"
capsConfigPath    = __dirname + "/caps_config"
config            = JSON.parse(fs.readFileSync(process.cwd() + "/config.json", "utf8"))[environment]
fs.readdirSync(capsConfigPath).filter((file) ->
  /.json$/.test(file)
).forEach (file) ->
  currency = file.replace ".json", ""
  cap = JSON.parse fs.readFileSync("#{capsConfigPath}/#{file}")
  config.caps.min[currency] = cap.min
  config.caps.max[currency] = cap.max
  return
exports = module.exports = ()->
  config