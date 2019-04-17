class App.LastPaymentsView extends App.MasterView

  el: null

  collection: null

  tpl: null

  initialize: ({@tpl})->
    @tpl = "last-payments-tpl"
    $.subscribe "payment-processed", @onPaymentProcessed
    $.subscribe "new-withdrawal-submited", @onNewWithdrawalSubmited
    App.Helpers.Sound.load "beep", {soundsPath: CONFIG.siteSoundsPath}

  render: ()->
    @collection.fetch
      success: ()=>
        @$el.html @template
          payments: @collection

  onPaymentProcessed: ()=>
    @render()
    $.publish "error", "Your payment was processed."
    App.Helpers.Sound.play "beep"

  onNewWithdrawalSubmited: ()=>
    @render()