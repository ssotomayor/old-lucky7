window.App or= {}

class window.App.ProvablyFairView

  el: null

  constructor: ({@el})->
    $.subscribe "hash-secret", @onHashSecret
    $.subscribe "client-seed", @onClientSeed
    $.subscribe "game-result", @onGameResult

  renderProvablyFairResult: (provablyFair)->
    $result = $(@el).find("#result")
    $result.find("#hash-secret").val provablyFair.hash_secret
    $result.find("#client-seed").val provablyFair.client_seed
    $result.find("#server-seed").val provablyFair.server_seed
    $result.find("#initial-shuffle").val provablyFair.initial_shuffle
    $result.find("#final-shuffle").val provablyFair.final_shuffle
    verifyUrl = $result.find("#verify-link").data("path") + "?" + encodeURI($.param provablyFair)
    $result.find("#verify-link").attr "href", verifyUrl

  getClientSeed: ()->
    $(@el).find("#current-game #client-seed").val()

  onHashSecret: (ev, hashSecret)=>
    $(@el).find("#current-game #hash-secret").val hashSecret

  onClientSeed: (ev, clientSeed)=>
    $(@el).find("#current-game #client-seed").val clientSeed

  onGameResult: (ev, result)=>
    @renderProvablyFairResult result.provably_fair