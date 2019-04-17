class App.LastTransactionsView extends App.MasterView

  el: null

  collection: null

  tpl: null

  initialize: ({@tpl})->
    @tpl = "last-transactions-tpl"
    $.subscribe "new-withdrawal-submited", @onNewWithdrawalSubmited
    $.subscribe "new-wallet-balance", @onNewWalletBalance

  render: ()->
    @collection.fetch
      success: ()=>
        @$el.html @template
          transactions: @collection

  onNewWalletBalance: ()=>
    @render()

  onNewWithdrawalSubmited: ()=>
    @render()