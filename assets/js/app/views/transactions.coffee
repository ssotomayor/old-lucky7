window.App or= {}

class window.App.TransactionsView

  el: null

  player: null

  $withdrawBox: null

  $depositBox: null

  $playModePopup: null

  $playerInfoBox: null

  $modalOverlay: null

  $playForMoneyPopup: null

  autoloadPlayerIntervalTime: 60000

  playedGames: 0

  balanceType: "balance"

  playWithBtcUrl: "/player"

  constructor: ({@el, @player, @$withdrawBox, @$depositBox, @$playerInfoBox, @$playModePopup, @$modalOverlay, @$playForMoneyPopup, @playWithBtcUrl})->
    $.subscribe "player-balance", @onPlayerBalance
    $.subscribe "new-wallet-balance", @onNewWalletBalance
    $.subscribe "game-result", @onGameResult

  render: (callback)->
    @loadPlayer ()=>
      @$depositBox.addClass('show') if @player.get(@balanceType) is 0 and not @$playerInfoBox
      @renderAddressBox()
      callback()
    $el = $(@el)
    $el.find("#play-with-btc").click @onPlayWithBtcClick
    $el.find("#withdraw-bt").click @onWithdrawClick
    $el.find("#deposit-bt").click @onDepositClick
    @$withdrawBox.find("#withdraw-form").submit @onWithdrawFormSubmit
    @$withdrawBox.find(".close-bt").click @onCloseBtClick
    @$depositBox.find("#show-qr-bt").click @onShowQrClick
    @$depositBox.find(".close-bt").click @onCloseBtClick
    @$depositBox.find("#open-buybtc").click @onBuybtcClick
    @$depositBox.find("#generate-address-bt").click @onGenerateAddressClick
    @$playModePopup.find("#chose-btc-play").click @onBtcPlayClick
    @$playModePopup.find("#chose-practice-play").click @onPracticePlayClick
    @$playerInfoBox.find(".close-bt").click @onCloseBtClick  if @$playerInfoBox and @$playerInfoBox.length
    @$playForMoneyPopup.find("#chose-btc-play").click @onBtcPlayClick  if @$playForMoneyPopup
    @$playForMoneyPopup.find("#chose-practice-play").click @onPracticePlayClick  if @$playForMoneyPopup
    @autoloadPlayerInterval = setInterval @loadPlayer, @autoloadPlayerIntervalTime
    App.Helpers.Sound.load "beep", {soundsPath: CONFIG.siteSoundsPath}

  renderBalance: (balance = 0, blink = true)->
    balance = Math.floor(parseFloat(balance) * 1000) / 1000
    $balance = $(@el).find("#balance")
    currentBalance = parseFloat $balance.text()
    $balance.text(balance)
    wrapperClass = if balance <= currentBalance then "lost" else "won"
    $(@el).find(".balance-wrapper")
    .removeClass("lost")
    .removeClass("won")
    if blink
      setTimeout ()=>
          $(@el).find(".balance-wrapper").addClass(wrapperClass)
        , 100
    showWithdraw = @player.get("type") is "premium"
    $(@el).find("#withdraw-bt").toggle showWithdraw

  renderAddressBox: ()->
    $depositAddress = @$depositBox.find("#deposit-address")
    $copyBt = @$depositBox.find("#copy-address")
    $qrBt = @$depositBox.find("#show-qr-bt")
    $generateAddressBt = @$depositBox.find("#generate-address-bt")
    if not @player.get("address")
      $generateAddressBt = @$depositBox.find("#generate-address-bt")
      $qrBt.hide()
      $copyBt.hide()
      $generateAddressBt.show()
    else
      labels =
        btc: "bitcoin"
        ltc: "litecoin"
        doge: "dogecoin"
      address = @player.get("address")
      $depositAddress.text address
      $qrBt.data "address", "#{labels[@player.get('selected_balance_type')]}:#{address}?label=SatoshiBet"
      $qrBt.show()
      $copyBt.attr "data-clipboard-text", address
      $copyBt.show()
      $generateAddressBt.hide()
      clip = new ZeroClipboard $copyBt[0],
        moviePath: "#{window.location.origin}/ZeroClipboard.swf"

  loadPlayer: (callback)=>
    @player.fetch
      success: ()=>
        @renderBalance @player.get @balanceType
        callback() if callback

  increasePlayedGames: (result)->
    return if not @$playForMoneyPopup
    @playedGames++
    if _.isNumber(result.charged_amount) and result.charged_amount >= 0 or _.isArray(result) and result[0].charged_amount >= 0
      if @playedGames > 10
        @$playForMoneyPopup.addClass "show"
        @playedGames = 0

  goPlayWithBtc: ()->
    $.ajax
      url: "/play_with_btc"
      type: "post"
      success: (player)=>
        window.location.href = "#{@playWithBtcUrl}/#{player.slug}?jc=1"
      error: ()->
        alert "An error occured. Please try again..."

  onPlayWithBtcClick: (ev)=>
    @goPlayWithBtc()

  onWithdrawClick: (ev)=>
    @$depositBox.removeClass('show')
    @$withdrawBox.toggleClass('show')

  onWithdrawFormSubmit: (ev)=>
    ev.preventDefault()
    $form = $(ev.target)
    $button = $form.find("button[type='submit']")
    amount = parseFloat $form.find("[name='amount']").val()
    address = $form.find("[name='address']").val()
    return $.publish "error", "Please specify a valid amount to withdraw."  if _.isNaN(amount) or not _.isNumber(amount)
    $button.attr "disabled", true
    $button.addClass "loading"
    withdrawal = new App.WithdrawalModel
      amount: amount
      address: address
    withdrawal.save null,
      success: ()=>
        @$withdrawBox.toggleClass('show')
        $.publish "new-withdrawal-submited"
      error: (model, xhr)->
        $.publish "error", xhr
        $.publish "new-withdrawal-submited"
      complete: ()->
        $button.removeClass "loading"
        $button.attr "disabled", false

  onDepositClick: (ev)=>
    @$withdrawBox.removeClass('show')
    @$depositBox.toggleClass('show')

  onCloseBtClick: (ev)=>
    ev.preventDefault()
    $(ev.target).parents(".modal")
    .first().removeClass('show')

  onBtcPlayClick: (ev)=>
    ev.preventDefault()
    @goPlayWithBtc()

  onPracticePlayClick: (ev)=>
    ev.preventDefault()
    @$playModePopup.remove()  if @$playModePopup
    @$modalOverlay.remove()  if @$modalOverlay
    @$playForMoneyPopup.removeClass("show")  if @$playForMoneyPopup

  onShowQrClick: (ev)=>
    ev.preventDefault()
    $qrCnt = @$depositBox.find("#qr-cnt")
    new QRCode @$depositBox.find("#qr-cnt")[0], $(ev.target).data("address") if $qrCnt.is(":empty")
    $qrCnt.wrapInner("<a href='#{$(ev.target).data("address")}' />")
    $qrCnt.toggle not $qrCnt.is(":visible")

  onBuybtcClick: (ev)=>
    ev.preventDefault()
    $buyBtc = @$depositBox.find("#buybtc")
    $buyBtc.toggle not $buyBtc.is(":visible")

  onGenerateAddressClick: (ev)=>
    ev.preventDefault()
    @player.set
      address: "pending"
    @player.save null,
      success: ()=>
        @renderAddressBox()

  onPlayerBalance: (ev, newBalance, inSync)=>
    @renderBalance newBalance, inSync

  onNewWalletBalance: (ev, newBalance)=>
    App.Helpers.Sound.play "beep"

  onGameResult: (ev, result)=>
    @increasePlayedGames result
