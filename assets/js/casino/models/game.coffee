window.App or= {}

class window.App.GameModel

  urlRoot: ""

  constructor: ({@urlRoot})->

  action: (name, options = {})->
    $.ajax
      url: "#{@urlRoot}/#{name}"
      type: options.type or "post"
      data: options.data
      dataType: "json"
      success: options.success
      error: options.error

  generateClientSeed: ()->
    CryptoJS.SHA256 "#{Math.random()}"
