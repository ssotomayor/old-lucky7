window.App or= {}

class App.LastWinsCollection extends Backbone.Collection

  url: "/last_wins"

  model: App.LastWinModel
