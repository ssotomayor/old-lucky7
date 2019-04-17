window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.Sound =
  
  sounds: {}

  isMute: 0

  cookieName: "mute"

  load: (name, options = {})->
    if not @sounds[name] and $.sound.support
      soundsPath = options.soundsPath or CONFIG.soundsPath
      @sounds[name] = $.sound.load "#{soundsPath}/#{name}", options

  play: (name, options = {})->
    @load name, options
    @sounds[name].play() if @sounds[name] and @isMute is 0

  stop: (name)->
    @sounds[name].pause() if @sounds[name]

  mute: ()->
    @isMute = 1
    @saveIsMute()

  unmute: ()->
    @isMute = 0
    @saveIsMute()

  saveIsMute: ()->
    $.cookie @cookieName, @isMute, {expires: 30, path: '/'}

  restoreIsMute: ()->
    if $.cookie @cookieName
      @isMute = parseInt($.cookie(@cookieName))
    else
      @isMute = 0