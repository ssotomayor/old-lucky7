(function() {
  var SessionStore, environment, exports, options, session;

  session = require("express-session");

  environment = process.env.NODE_ENV || "development";

  SessionStore = environment === "development" ? require("connect-mongo")(session) : require("connect-dynamodb")({
    session: session
  });

  options = environment === "development" ? GLOBAL.appConfig().session.store : {
    client: GLOBAL.dynamodb,
    table: "sessions_" + environment
  };

  exports = module.exports = new SessionStore(options);

}).call(this);
