crypto = require "crypto"

class Crypter

  configPath: "config.json"

  algorithm: null

  key: null

  constructor: (options)->
    @configPath = options.configPath if options and options.configPath
    options = @loadOptionsFromFile() if not options
    @setupOptions options

  setupOptions: (options)->
    @algorithm = options.algorithm
    @key = options.key

  encode: (value)->
    cipher = crypto.createCipher @algorithm, @key
    enc = cipher.update value, "utf8", "hex"
    enc += cipher.final "hex"

  decode: (value)->
    decipher = crypto.createDecipher @algorithm, @key
    enc = decipher.update value, "hex", "utf8"
    enc += decipher.final "utf8"

  md5: (value)->
    crypto.createHash("md5").update("#{value}#{@key}", "utf8").digest("hex")

  loadOptionsFromFile: ()->
    options = GLOBAL.appConfig()
    if not options
      fs = require "fs"
      environment = process.env.NODE_ENV or "development"
      options = JSON.parse(fs.readFileSync("#{process.cwd()}/#{@configPath}", "utf8"))[environment]
    options.crypter

exports = module.exports = Crypter