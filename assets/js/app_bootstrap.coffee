$(document).ready ()->

  $.tmpload.defaults.tplWrapper = _.template
  $(document).ajaxSend (ev, xhr)->
    xhr.setRequestHeader "X-CSRF-Token", CONFIG.csrf

  errorLogger = new App.ErrorLogger

  _.str.roundTo = (number, decimals = 8)->
    multiplier = Math.pow(10, decimals)
    Math.round(parseFloat(number) * multiplier) / multiplier

  _.str.roundToThree = (number)->
    _.str.roundTo(number, 3)

  App.Helpers.MBP.startupImage()

  player = new App.PlayerModel
  player.openUpdateSocket()

  provablyFair = new App.ProvablyFairView
    el: $("#provably-fair-wrapper")

  if CONFIG.playGame is "lucky7" and $("#g-lucky7").length
    game = new Lucky7.Game
      el: $("#g-lucky7")
      player: player
      provablyFair: provablyFair
      urlRoot: "/lucky7"

  $("#view-help").click (ev)->
    ev.preventDefault()
    $("#help").toggleClass('active')

  $("#help").find(".close-bt").click (ev)->
    ev.preventDefault()
    $("#help").removeClass('active')

  $(".provably-fair-toggle").click (ev)->
    ev.preventDefault()
    $(this).toggleClass('active')
    $("#provably-fair-data").toggle()

  App.Helpers.Sound.restoreIsMute()
  if App.Helpers.Sound.isMute
    $(".sound-toggle span").removeClass("icon-soundon").addClass("icon-soundoff")
    
  $(".sound-toggle").on 'click', (ev)->
    ev.preventDefault()
    $icon = $(this).find('span')
    if $icon.hasClass "icon-soundon"
      App.Helpers.Sound.mute()
      $icon.removeClass "icon-soundon"
      $icon.addClass "icon-soundoff"
    else
      App.Helpers.Sound.unmute()
      $icon.removeClass "icon-soundoff"
      $icon.addClass "icon-soundon"

  $("#keyboard-shortcuts-toggle").on 'click', (ev)->
    ev.preventDefault()
    $("#shortcuts-modal").toggleClass('show fadeInUp')

  $("#shortcuts-modal").find(".close-bt").on 'click', (ev)->
    ev.preventDefault()
    $("#shortcuts-modal").removeClass('show fadeInUp')

  $("#currency-switch li").click (ev)->
    ev.preventDefault()
    pl = new App.PlayerModel
      id: player.id
    pl.save {currency: $(ev.currentTarget).data("currency")},
      success: ()->
        window.location.reload()

  $lastWinsCnt = $("#last-wins-cnt")

  if $lastWinsCnt.length
    lastWins = new App.LastWinsView
      el: $lastWinsCnt
      collection: new App.LastWinsCollection
      player: player
    lastWins.render()

  $("#settings #username").blur (ev)->
    $target = $(ev.target)
    username = $target.val()
    pl = new App.PlayerModel
      id: player.id
    pl.save {username: username},
      success: (pl, response)->
        $(".username-text").text pl.get "username"
      error: (pl, response)->
        $.publish "error", response

  $("#settings #email").blur (ev)->
    $target = $(ev.target)
    email = $target.val()
    pl = new App.PlayerModel
      id: player.id
    pl.save {email: email},
      success: (pl, response)->
        $(".email-text").text pl.get "email"
      error: (pl, response)->
        $.publish "error", response

  $("#settings #set-password-bt").click (ev)->
    $password = $("#settings #password")
    password = $password.val()
    $repeatPassword = $("#settings #repeat_password")
    repeatPassword = $repeatPassword.val()
    return $.publish "error", "The password is too short. It should contain minimum 5 characters."  if password.length < 5
    return $.publish "error", "The passwords do not match."  if password isnt repeatPassword
    pl = new App.PlayerModel
      id: player.id
    pl.save {password: password},
      success: (pl, response)->
        $.publish "error", "Your password was successfully set."
      error: (pl, response)->
        $.publish "error", response

  $("#login-form").submit (ev)->
    ev.preventDefault()
    $form = $(ev.target)
    pl = new App.PlayerModel
      username: $form.find("[name='username']").val()
      password: $form.find("[name='password']").val()
    pl.url = $form.attr("action")
    pl.save null,
      success: ()->
        window.location = "/player/#{pl.get('slug')}"
      error: (pl, response)->
        $.publish "error", response
