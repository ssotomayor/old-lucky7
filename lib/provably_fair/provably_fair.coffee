crypto   = require "crypto"
mersenne = require "mersenne"

class ProvablyFair

  collection: null

  initialShuffle: null

  serverSeed: null

  clientSeed: null

  finalShuffle: null

  constructor: (options = {})->
    @collection = options.collection
    @initialShuffle = @stringifyCollection @collection  if @collection
    @serverSeed = options.serverSeed
    @clientSeed = options.clientSeed

  stringifyCollection: ()->

  hash: (value)->
    crypto.createHash("sha256").update("#{value}", "utf8").digest("hex")

  random: ()->
    @hash Math.random()

  hashSecret: ()->
    @serverSeed = @serverSeed or @random()
    @hash "#{@serverSeed}#{@initialShuffle}"

  finalShuffle: ()->
    seed = @hash("#{@clientSeed}#{@serverSeed}")
    seed = parseInt(seed.substring(seed.length - 8), 16)
    mt = new mersenne.MersenneTwister19937()
    mt.init_genrand(seed)
    @finalShuffled = @fisherYatesShuffle(@collection, mt)

  fisherYatesShuffle: (collection, twister)->
    tmp = undefined
    i = collection.length - 1
    while i > 0
      r = twister.genrand_int32() % (i + 1)
      tmp = collection[r]
      collection[r] = collection[i]
      collection[i] = tmp
      i--
    collection

  result: ()->
    client_seed: @clientSeed
    hash_secret: @hashSecret()
    server_seed: @serverSeed
    initial_shuffle: @initialShuffle
    final_shuffle: @stringifyCollection(@finalShuffled)

exports = module.exports = ProvablyFair