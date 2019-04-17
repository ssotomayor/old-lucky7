io                = require "socket.io"
SessionSockets    = require "session.socket.io"
redis             = require "redis"
SocketsRedisStore = require "socket.io/lib/stores/redis"
socketPub         = redis.createClient GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {auth_pass: GLOBAL.appConfig().redis.pass}
socketSub         = redis.createClient GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {auth_pass: GLOBAL.appConfig().redis.pass}
socketClient      = redis.createClient GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {auth_pass: GLOBAL.appConfig().redis.pass}
externalEventsSub = redis.createClient GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {auth_pass: GLOBAL.appConfig().redis.pass}

sockets = {}

initSockets = (server, env, sessionStore, cookieParser)->
  ioOptions =
    log: if env is "production" then false else false
  
  sockets.io = io.listen server, ioOptions

  sockets.io.configure "production", ()->
    sockets.io.enable "browser client minification"
    sockets.io.enable "browser client etag"
    sockets.io.enable "browser client gzip"
    sockets.io.set "origins", "#{GLOBAL.appConfig().players.hostname}:*"

  sockets.io.set "store", new SocketsRedisStore
    redis: redis
    redisPub: socketPub
    redisSub: socketSub
    redisClient: socketClient

  externalEventsSub.subscribe "external-events"
  externalEventsSub.on "message", (channel, data)->
    if channel is "external-events"
      try
        data = JSON.parse data
        if data.namespace is "players"
          for sId, so of sockets.io.of("/players").sockets
            so.emit data.type, data.eventData  if so.player_id is data.player_id
        if data.namespace is "game_stats"
          sockets.io.of("/game_stats").emit data.type, data.eventData
      catch e
        console.error "Could not emit to socket #{data}: #{e}"
      @

  sockets.sessionSockets = new SessionSockets sockets.io, sessionStore, cookieParser, GLOBAL.appConfig().session.session_key

  sockets.sessionSockets.of("/players").on "connection", (err, socket, session)->
    if session and session.player
      try
        player = JSON.parse session.player
        socket.player_id = player.id
      catch e
  
  sockets.io.of("/game_stats").on "connection", (socket)->

  sockets

exports = module.exports = initSockets