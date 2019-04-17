(function() {
  var SessionSockets, SocketsRedisStore, exports, externalEventsSub, initSockets, io, redis, socketClient, socketPub, socketSub, sockets;

  io = require("socket.io");

  SessionSockets = require("session.socket.io");

  redis = require("redis");

  SocketsRedisStore = require("socket.io/lib/stores/redis");

  socketPub = redis.createClient(GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {
    auth_pass: GLOBAL.appConfig().redis.pass
  });

  socketSub = redis.createClient(GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {
    auth_pass: GLOBAL.appConfig().redis.pass
  });

  socketClient = redis.createClient(GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {
    auth_pass: GLOBAL.appConfig().redis.pass
  });

  externalEventsSub = redis.createClient(GLOBAL.appConfig().redis.port, GLOBAL.appConfig().redis.host, {
    auth_pass: GLOBAL.appConfig().redis.pass
  });

  sockets = {};

  initSockets = function(server, env, sessionStore, cookieParser) {
    var ioOptions;
    ioOptions = {
      log: env === "production" ? false : false
    };
    sockets.io = io.listen(server, ioOptions);
    sockets.io.configure("production", function() {
      sockets.io.enable("browser client minification");
      sockets.io.enable("browser client etag");
      sockets.io.enable("browser client gzip");
      return sockets.io.set("origins", "" + (GLOBAL.appConfig().players.hostname) + ":*");
    });
    sockets.io.set("store", new SocketsRedisStore({
      redis: redis,
      redisPub: socketPub,
      redisSub: socketSub,
      redisClient: socketClient
    }));
    externalEventsSub.subscribe("external-events");
    externalEventsSub.on("message", function(channel, data) {
      var e, sId, so, _ref;
      if (channel === "external-events") {
        try {
          data = JSON.parse(data);
          if (data.namespace === "players") {
            _ref = sockets.io.of("/players").sockets;
            for (sId in _ref) {
              so = _ref[sId];
              if (so.player_id === data.player_id) {
                so.emit(data.type, data.eventData);
              }
            }
          }
          if (data.namespace === "game_stats") {
            sockets.io.of("/game_stats").emit(data.type, data.eventData);
          }
        } catch (_error) {
          e = _error;
          console.error("Could not emit to socket " + data + ": " + e);
        }
        return this;
      }
    });
    sockets.sessionSockets = new SessionSockets(sockets.io, sessionStore, cookieParser, GLOBAL.appConfig().session.session_key);
    sockets.sessionSockets.of("/players").on("connection", function(err, socket, session) {
      var e, player;
      if (session && session.player) {
        try {
          player = JSON.parse(session.player);
          return socket.player_id = player.id;
        } catch (_error) {
          e = _error;
        }
      }
    });
    sockets.io.of("/game_stats").on("connection", function(socket) {});
    return sockets;
  };

  exports = module.exports = initSockets;

}).call(this);
