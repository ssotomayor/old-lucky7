window.App = window.App or {}
window.App.Helpers = window.App.Helpers or {}
window.App.Helpers.MBP = window.App.Helpers.MBP or {}

###
iOS Startup Image helper
###
App.Helpers.MBP.startupImage = ->
  portrait = undefined
  landscape = undefined
  pixelRatio = undefined
  head = undefined
  link1 = undefined
  link2 = undefined
  pixelRatio = window.devicePixelRatio
  head = document.getElementsByTagName("head")[0]
  if navigator.platform is "iPad"
    portrait = (if pixelRatio is 2 then "/img/startup/startup-tablet-portrait-retina.png" else "/img/startup/startup-tablet-portrait.png")
    landscape = (if pixelRatio is 2 then "/img/startup/startup-tablet-landscape-retina.png" else "/img/startup/startup-tablet-landscape.png")
    link1 = document.createElement("link")
    link1.setAttribute "rel", "apple-touch-startup-image"
    link1.setAttribute "media", "screen and (orientation: portrait)"
    link1.setAttribute "href", portrait
    head.appendChild link1
    link2 = document.createElement("link")
    link2.setAttribute "rel", "apple-touch-startup-image"
    link2.setAttribute "media", "screen and (orientation: landscape)"
    link2.setAttribute "href", landscape
    head.appendChild link2
  else
    portrait = (if pixelRatio is 2 then "/img/startup/startup-retina.png" else "/img/startup/startup.png")
    portrait = (if screen.height is 568 then "/img/startup/startup-retina-4in.png" else portrait)
    link1 = document.createElement("link")
    link1.setAttribute "rel", "apple-touch-startup-image"
    link1.setAttribute "href", portrait
    head.appendChild link1
  
  # hack to fix letterboxed full screen web apps on 4 iPhone / iPod
  App.Helpers.MBP.viewportmeta.content = App.Helpers.MBP.viewportmeta.content.replace(/\bwidth\s*=\s*320\b/, "width=320.1").replace(/\bwidth\s*=\s*device-width\b/, "")  if App.Helpers.MBP.viewportmeta  if (navigator.platform is "iPhone" or "iPod") and (screen.height is 568)