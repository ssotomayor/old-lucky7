window.App or= {}

class App.TransactionsCollection extends Backbone.Collection

  urlRoot: "/transactions"

  model: App.TransactionModel

  from: 0

  limit: 10

  initialize: (models, options = {})->
    @from = options.from or @from
    @limit = options.limit or @limit

  url: ()->
    "#{@urlRoot}?from=#{@from}&count=#{@limit}"