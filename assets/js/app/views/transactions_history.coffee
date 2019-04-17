window.App or= {}

class window.App.TransactionsHistoryView extends App.MasterView

  el: null

  depositsCollection: null

  paymentsCollection: null

  events:
    "click .load-more-payments": "onLoadMorePaymentsClick"
    "click .load-more-deposits": "onLoadMoreDepositsClick"

  initialize: ({@depositsCollection, @paymentsCollection})->
    $.subscribe "payment-processed", @onPaymentProcessed
    $.subscribe "new-withdrawal-submited", @onNewWithdrawalSubmited
    $.subscribe "new-wallet-balance", @onNewWalletBalance
    App.Helpers.Sound.load "beep", {soundsPath: CONFIG.siteSoundsPath}

  render: ()->
    @renderDeposits()
    @renderPayments()

  renderDeposits: (empty = false)->
    @depositsCollection.fetch
      success: ()=>
        @tpl = "transactions-tpl"
        $cnt = @$("#transactions-cnt tbody")
        $cnt.empty()  if empty
        $cnt.append @template
          transactions: @depositsCollection
        @$(".load-more-deposits").hide()  if @depositsCollection.length < @depositsCollection.limit

  renderPayments: (empty = false)->
    @paymentsCollection.fetch
      success: ()=>
        @tpl = "payments-tpl"
        $cnt = @$("#payments-cnt tbody")
        $cnt.empty()  if empty
        $cnt.append @template
          payments: @paymentsCollection
        @$(".load-more-payments").hide()  if @paymentsCollection.length < @paymentsCollection.limit

  onNewWalletBalance: (ev, newBalance)=>
    @depositsCollection.from = 0
    @renderDeposits true
    $.publish "error", "Your deposit arrived."
    App.Helpers.Sound.play "beep"

  onNewWithdrawalSubmited: ()=>
    @paymentsCollection.from = 0
    @renderPayments true

  onPaymentProcessed: ()=>
    @paymentsCollection.from = 0
    @renderPayments true
    $.publish "error", "Your payment was processed."
    App.Helpers.Sound.play "beep"

  onLoadMorePaymentsClick: (ev)->
    $bt = $(ev.currentTarget)
    @paymentsCollection.from += @paymentsCollection.limit
    @renderPayments()

  onLoadMoreDepositsClick: (ev)->
    $bt = $(ev.currentTarget)
    @depositsCollection.from += @depositsCollection.limit
    @renderDeposits()
