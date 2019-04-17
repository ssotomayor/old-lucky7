SlotMachine             = require "../../lib/casino/slot_machine"
TempGame                = require "../../models/temp_game"
ProvablyFairSlotMachine = require "../../lib/provably_fair/provably_fair_slot_machine"
AppHelper               = require "../../lib/app_helper"
JsonRenderer            = require "../../lib/json_renderer"

module.exports = (app)->

  app.post "/lucky7/shuffle", (req, res)->
    response = {}
    TempGame.findInProgress "lucky7", (err, tempGame = null)->
      console.error err  if err
      game = null
      if tempGame
        game = new SlotMachine
          session: tempGame.game_data
      else
        game = new SlotMachine
          maxCap: 10000000000000
          minCap: 1
          currency: "free"
          playerId: 1
          playerUid: "123"
        game.shuffleReels()
      provablyFair = new ProvablyFairSlotMachine
        collection: game.getReels()
      hashSecret = provablyFair.hashSecret()
      response.hash_secret = hashSecret
      TempGame.store tempGame, game, provablyFair.serverSeed, null, (err)->
        console.error err  if err
        res.json JsonRenderer.gameResponse game, response

  app.post "/lucky7/spin", (req, res)->
    response = {}
    wager = AppHelper.balanceFromFloat parseFloat(req.body.wager), "free"
    clientSeed = req.body.client_seed
    TempGame.findInProgress "lucky7", (err, tempGame = null)->
      console.error err  if err
      return JsonRenderer.error "There is no started game.", res  if not tempGame
      game = new SlotMachine
        session: tempGame.game_data
      provablyFair = new ProvablyFairSlotMachine
        collection: game.getReels()
        serverSeed: tempGame.server_seed
        clientSeed: clientSeed
      finalShuffledReels = provablyFair.finalShuffle()
      game.setReels finalShuffledReels
      return JsonRenderer.error "You can not bet. The wager must be between the specified boundaries.", res  if not game.bet(wager)
      result = game.spin()
      return JsonRenderer.error "You can not spin.", res  if not result
      return JsonRenderer.error "Game error...your funds are safe.", res  if not game.isOver()
      response = result
      diffBalance = game.getAmount()
      response.balance = 100000000000
      response.provably_fair = provablyFair.result()
      response.provably_fair.game_type = "lucky7"
      TempGame.purge tempGame, game, (err)->
        console.error err  if err
        res.json JsonRenderer.gameResponse game, response
