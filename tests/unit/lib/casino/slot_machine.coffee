require "./../../../helpers/spec_helper"
SlotMachine = require "./../../../../lib/casino/slot_machine"

describe "SlotMachine", ->
  slotMachine = undefined

  before ->
    slotMachine = new SlotMachine


  describe "constructor", ->
    it "can be initialized with session options", ->
      sm = new SlotMachine
        minCap: "min_cap"
        maxCap: "max_cap"
        currency: "currency"
        playerId: "playerId"
        playerUid: "playerUid"
        linesCount: 2
      sm.session.should.eql
        name: "lucky7"
        minCap: "min_cap"
        maxCap: "max_cap"
        currency: "currency"
        playerId: "playerId"
        playerUid: "playerUid"
        linesCount: 2
        steps: []
        reels: []
        wager: null
        totalAmount: 0
    it "can be initialized with JSON stringifyed session", ->
      session = JSON.stringify
        minCap: "min_cap"
        maxCap: "max_cap"
      sm = new SlotMachine
        session: session
      sm.session.should.eql
        minCap: "min_cap"
        maxCap: "max_cap"
    it "has a default minCap", ->
      sm = new SlotMachine
      sm.session.minCap.should.eql 100000000
    it "has a default maxCap", ->
      sm = new SlotMachine
      sm.session.maxCap.should.eql 100000000000
    it "has a default number of lines", ->
      sm = new SlotMachine
      sm.session.linesCount.should.eql 1


  describe "shuffleReels", ->
    describe "when there are no steps", ->
      beforeEach ->
        slotMachine.session.steps = []
      it "sets the shuffled reels", ->
        slotMachine.shuffleReels()
        slotMachine.session.reels.length.should.eql 3
      it "adds the shuffle_reels step", ->
        slotMachine.shuffleReels()
        slotMachine.session.steps[0].should.eql "shuffle_reels"
      it "returns the shuffled reels", ->
        reels = slotMachine.shuffleReels()
        slotMachine.session.reels.should.eql reels

    describe "when there are steps", ->
      it "returns false", ->
        slotMachine.session.steps = ["step"]
        slotMachine.shuffleReels().should.be.false


  describe "bet", ->
    wager = 10
    beforeEach ->
      slotMachine.session.minCap = 1
      slotMachine.session.maxCap = 1000
      slotMachine.session.steps = ["shuffle_reels"]
      slotMachine.session.wager = null
    describe "when the last step is shuffle_reels and the wager is ok", ->
      beforeEach ->
        slotMachine.session.wager = null
      it "sets the wager", ->
        slotMachine.bet wager
        slotMachine.session.wager.should.eql wager
      it "adds the bet_wager step", ->
        slotMachine.bet wager
        lastStep = slotMachine.session.steps[slotMachine.session.steps.length - 1]
        lastStep.should.eql "bet_wager"
      it "returns true", ->
        slotMachine.bet(wager).should.be.true
    
    describe "when the last step is not shuffle_reels", ->
      it "returns false", ->
        slotMachine.session.steps = ["bug"]
        slotMachine.bet(wager).should.be.false
    
    describe "when the wager is not ok", ->
      it "returns false", ->
        slotMachine.bet("bug", 3).should.be.false


  describe "spin", ->
    describe "when the last step is shuffle_reels", ->
      beforeEach ->
        slotMachine.session.steps = ["bet_wager"]
        slotMachine.session.reels = [["a"], ["a"], ["a"]]
        slotMachine.session.wager = 5
        slotMachine.spin()
      it "adds the spin step", ->
        slotMachine.session.steps[1].should.eql "spin"
      it "adds the total amount", ->
        slotMachine.session.totalAmount.should.match(/[5,-5]/)
      it "adds the amount step", ->
        slotMachine.session.steps[2].should.match(/(add_amount_5)|(add_amount_-5)/)
      it "adds the game over step", ->
        slotMachine.session.steps[3].should.eql "game_over"
    
    describe "when the last step is not shuffle_reels", ->
      it "returns false", ->
        slotMachine.session.steps = ["step"]
        slotMachine.spin().should.be.false


  describe "getLuckyLines", ->
    describe "when there are reels", ->
      beforeEach ->
        slotMachine.session.linesCount = 2
        slotMachine.session.reels = [["bw", "b1"], ["bw", "b1"], ["bw", "b1"]]
      it "returns the lines that have a win", ->
        slotMachine.getLuckyLines().should.eql [["bw", "bw", "bw"], ["b1", "b1", "b1"]]

    describe "when there are no reels", ->
      beforeEach ->
        slotMachine.session.reels = []
      it "returns null", ->
        (slotMachine.getLuckyLines() is null).should.be.true


  describe "getLineReward", ()->
    beforeEach ->
      slotMachine.session.wager = 5

    describe "when the given line contains 3 bw", ()->
      it "returns the wager", ()->
        slotMachine.getLineReward(["bw", "bw", "bw"]).should.eql 5
    
    describe "when the given line contains 3 l7", ()->
      it "returns 500 times the wager", ()->
        slotMachine.getLineReward(["l7", "l7", "l7"]).should.eql 2500

    describe "when the given line contains 3 bt", ()->
      it "returns 100 times the wager", ()->
        slotMachine.getLineReward(["bt", "bt", "bt"]).should.eql 500

    describe "when the given line contains 3 b3", ()->
      it "returns 30 times the wager", ()->
        slotMachine.getLineReward(["b3", "b3", "b3"]).should.eql 150

    describe "when the given line contains 3 b2", ()->
      it "returns 20 times the wager", ()->
        slotMachine.getLineReward(["b2", "b2", "b2"]).should.eql 100

    describe "when the given line contains 3 b1", ()->
      it "returns 10 times the wager", ()->
        slotMachine.getLineReward(["b1", "b1", "b1"]).should.eql 50

    describe "when the given line contains any 2 bt", ()->
      it "returns 5 times the wager", ()->
        slotMachine.getLineReward(["bt", "b1", "bt"]).should.eql 25

    describe "when the given line contains 3 bs of any kind", ()->
      it "returns 2 times the wager", ()->
        slotMachine.getLineReward(["b1", "b2", "b3"]).should.eql 10

    describe "when the given line contains any bt", ()->
      it "returns 1 times the wager", ()->
        slotMachine.getLineReward(["b3", "b1", "bt"]).should.eql 5

    describe "when non of above", ()->
      it "returns 0", ()->
        slotMachine.getLineReward(["l7", "b1", "zo"]).should.eql 0


  describe "getTotalReward", ()->
    beforeEach ->
      slotMachine.session.linesCount = 2
      slotMachine.session.wager = 5
      slotMachine.session.reels = [["bw", "b1"], ["bw", "b1"], ["bw", "b1"]]
    it "returns the total reward from the lucky lines", ()->
      slotMachine.getTotalReward().should.eql 55


  describe "getAmount", ->
    beforeEach ->
      slotMachine.session.totalAmount = 10
    it "returns the player total won amount", ->
      slotMachine.getAmount().should.eql 10


  describe "getWager", ->
    beforeEach ->
      slotMachine.session.wager = 10
    it "returns the player wager", ->
      slotMachine.getWager().should.eql 10


  describe "getResult", ->
    beforeEach ->
      slotMachine.session.reels = [
        ["bw", "b", "c"]
        ["bw", "c", "b"]
        ["bw", "c", "a"]
      ]
      slotMachine.session.totalAmount = 5
    it "returns the game result object", ->
      slotMachine.getResult(chargedAmount: 5).should.eql
        reels: [
          ["bw", "b", "c"]
          ["bw", "c", "b"]
          ["bw", "c", "a"]
        ]
        result: [
          ["bw", "bw", "bw"]
        ]
        charged_amount: 5


  describe "getReels", ->
    beforeEach ->
      slotMachine.session.reels = "reels"
    it "returns the session reels", ->
      slotMachine.getReels().should.eql "reels"


  describe "setReels", ->
    beforeEach ->
      slotMachine.session.reels = []
    it "sets the a clone of the given reels in the session", ->
      slotMachine.setReels(["reels"])
      slotMachine.session.reels.should.eql ["reels"]
    it "sets the a clone of the given reels in the session", ->
      slotMachine.setReels(["many reels"]).should.eql ["many reels"]


  describe "getWinEdge", ()->
    it "returns 0.0168", ()->
      slotMachine.getWinEdge().should.eql 0.004


  describe "isValidWager", ->
    beforeEach ->
      slotMachine.session.minCap = 10
      slotMachine.session.maxCap = 15
    describe "when it's a number bigger or equal than minCap and lower or equal than maxCap", ->
      it "returns true", ->
        slotMachine.isValidWager(10).should.eql true

    describe "when it's a number lower than minCap", ->
      it "returns false", ->
        slotMachine.isValidWager(9).should.eql false

    describe "when it's a number higher than maxCap", ->
      it "returns false", ->
        slotMachine.isValidWager(16).should.eql false

    describe "when it's not a number", ->
      it "returns false", ->
        slotMachine.isValidWager("bug").should.eql false


  describe "isOver", ->
    describe "when the game is over", ->
      beforeEach ->
        slotMachine.session.steps = ["game_over"]
      it "returns true", ->
        slotMachine.isOver().should.be.true

    describe "when the game is not over", ->
      beforeEach ->
        slotMachine.session.steps = []
      it "returns false", ->
        slotMachine.isOver().should.be.false


  describe "isWin", ->
    describe "when the game balance is 0 or more", ->
      beforeEach ->
        slotMachine.session.totalAmount = 1
        slotMachine.session.reels = [
          ["bw", "b1", "b3"]
          ["bw", "b2", "b1"]
          ["bw", "b3", "bt"]
        ]
      it "returns true", ->
        slotMachine.isWin().should.be.true

    describe "when the game balance is less than 0", ->
      beforeEach ->
        slotMachine.session.totalAmount = -1
        slotMachine.session.reels = [
          ["b1", "bw", "b3"]
          ["bw", "b2", "b1"]
          ["bw", "b3", "bt"]
        ]
      it "returns false", ->
        slotMachine.isWin().should.be.false


  describe "isJackpot", ->
    describe "when the game has bw as a lucky line", ->
      beforeEach ->
        slotMachine.session.reels = [
          ["bw", "b1", "b3"]
          ["bw", "b2", "b1"]
          ["bw", "b3", "bt"]
        ]
      it "returns true", ->
        slotMachine.isJackpot().should.be.true

    describe "when the game has no bw as a lucky line", ->
      beforeEach ->
        slotMachine.session.reels = [
          ["b1", "bw", "b3"]
          ["b1", "b2", "b1"]
          ["b1", "b3", "bt"]
        ]
      it "returns false", ->
        slotMachine.isJackpot().should.be.false


  describe "chargeAmount", ->
    luckyLines = undefined
    beforeEach ->
      slotMachine.session.steps = []
      slotMachine.session.totalAmount = 0
      luckyLines = [[0, 0, 0]]
    
    it "adds the given amount to the player's total won amount", ->
      slotMachine.chargeAmount(5, luckyLines)
      slotMachine.session.totalAmount.should.eql 5
    it "adds the amount step", ->
      slotMachine.chargeAmount(5, luckyLines)
      slotMachine.session.steps[0].should.eql "add_amount_5"
    it "returns the given amount", ->
      slotMachine.chargeAmount(5, luckyLines).should.eql 5


  describe "addStep", ->
    beforeEach ->
      slotMachine.session.steps = ["step1"]
    it "adds a step at the end of the stack", ->
      slotMachine.addStep("step2")
      slotMachine.session.steps[1].should.eql "step2"
    it "returns the length of the steps collection", ->
      slotMachine.addStep("step2").should.eql 2


  describe "isLastStep", ->
    beforeEach ->
      slotMachine.session.steps = ["step1"]
    describe "when the last step in the steps collection is the given one", ->
      it "returns true", ->
        slotMachine.isLastStep("step1").should.eql true

    describe "when the last step in the steps collection is not the given one", ->
      it "returns false", ->
        slotMachine.isLastStep("step2").should.eql false


  describe "pack", ->
    it "returns a stringifyed JSON version of the game data", ->
      slotMachine.pack().should.eql JSON.stringify(slotMachine.session)

  
  describe "unpack", ->
    session = undefined
    stringifyedSession = undefined
    beforeEach ->
      session =
        totalAmount: 10
      stringifyedSession = JSON.stringify session
    it "sets the game session data from a stringifyed JSON", ->
      slotMachine.unpack(stringifyedSession)
      slotMachine.session.should.eql session
    it "returns the session data", ->
      slotMachine.unpack(stringifyedSession).should.eql session

