mersenne     = require "mersenne"
ProvablyFair = require "./provably_fair"

class ProvablyFairSlotMachine extends ProvablyFair

  stringifyCollection: (collection)->
    stringifiedCollection = ""
    for reel in collection
      for item in reel
        stringifiedCollection += "#{item}|"
      stringifiedCollection = stringifiedCollection.substr 0, stringifiedCollection.length - 1
      stringifiedCollection += "-"
    stringifiedCollection.substr 0, stringifiedCollection.length - 1

  finalShuffle: ()->
    seed = @hash("#{@clientSeed}#{@serverSeed}")
    seed = parseInt(seed.substring(seed.length - 8), 16)
    mt = new mersenne.MersenneTwister19937()
    mt.init_genrand(seed)
    @finalShuffled = []
    for reel in @collection
      @finalShuffled.push @fisherYatesShuffle(reel, mt)
    @finalShuffled

exports = module.exports = ProvablyFairSlotMachine