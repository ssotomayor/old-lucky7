AppHelper = require "../lib/app_helper"

TempGameSchema = new Schema
  player_id:
    type: String
    index: true
  currency:
    type: String
    enum: AppHelper.getCurrencies()
    default: "free"
  name:
    type: String
    enum: AppHelper.getGameNames()
  is_over:
    type: Boolean
    default: false
    index: true
  game_data:
    type: String
  server_seed:
    type: String
  provably_fair_result:
    type: {}
  created:
    type: Date
    default: Date.now
    index: true

TempGameSchema.set("autoIndex", false)

TempGameSchema.statics.store = (tempGame, game, serverSeed, provablyFairResult, callback = ()->)->
  tempGame = new TempGame  if not tempGame
  tempGame.player_id = game.getPlayerId()
  tempGame.currency = game.getCurrency()
  tempGame.name = game.getName()
  tempGame.is_over = game.isOver()
  tempGame.game_data = game.pack()
  tempGame.server_seed = serverSeed  if serverSeed
  tempGame.provably_fair_result = provablyFairResult  if provablyFairResult
  tempGame.save callback

TempGameSchema.statics.findInProgress = (name, callback = ()->)->
  TempGame.findOne {player_id: 1, currency: "free", name: name, is_over: false}, callback

TempGameSchema.statics.purge = (tempGame, game, callback = ()->)->
  TempGame.store tempGame, game, null, null, callback

TempGame = mongoose.model("TempGame", TempGameSchema)
exports = module.exports = TempGame