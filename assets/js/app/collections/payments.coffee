window.App or= {}

class App.PaymentsCollection extends Backbone.Collection

  urlRoot: "/payments"

  model: App.PaymentModel

  from: 0

  limit: 10

  initialize: (models, options = {})->
    @from = options.from or @from
    @limit = options.limit or @limit

  url: ()->
    "#{@urlRoot}?from=#{@from}&count=#{@limit}"