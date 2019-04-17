
/**
 * Module dependencies.
 */

var express        = require('express');
var bodyParser     = require('body-parser');
var methodOverride = require('method-override');
var cookieParser   = require('cookie-parser');
var session        = require('express-session');
var compression    = require('compression');
var csrf           = require('csurf');
var errorhandler   = require('errorhandler');
var http           = require('http');
var io             = require('socket.io');
var util           = require('util');
var helmet         = require('helmet');
var i18n           = require("i18n");
var environment    = process.env.NODE_ENV || 'development';
var Crypter        = require("./lib/crypter");


// Configure globals
GLOBAL.appConfig = require("./config/config");

require('date-utils');

if (environment === "production") {
  require("./config/logger");
}
if (environment !== "production") {
  require('./models/db_connect_mongo');
}

GLOBAL.crypter  = new Crypter();

var validLocales     = {en: "English"};
var validLocalesAbbr = Object.keys(validLocales);
i18n.configure({
  locales: validLocalesAbbr,
  cookie: "locales",
  directory: __dirname + "/locales",
  updateFiles: environment === 'production' ? false : true
});


// Setup express
var app = express();
var cookieParser  = cookieParser(GLOBAL.appConfig().session.cookie_secret);
var sessionStore  = require("./lib/session_store");
var connectAssets = require("./lib/assets")(app);
app.enable("trust proxy");
app.disable('x-powered-by');
app.set('port', process.env.PORT || 5000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(compression());
app.use(bodyParser());
app.use(methodOverride());
app.use(cookieParser);
app.use(session({
  name:              GLOBAL.appConfig().session.session_key,
  secret:            GLOBAL.appConfig().session.cookie_secret,
  store:             sessionStore,
  proxy:             true,
  cookie:            GLOBAL.appConfig().session.cookie,
  saveUninitialized: true,
  resave:            true
}));
app.use(i18n.init);
app.use(function(req, res, next) {
  if (validLocalesAbbr.indexOf(req.query.l) > -1) {
    res.cookie("locales", req.query.l, {path: "/", maxAge: 2592000000, httpOnly: true, secure: false});
    i18n.setLocale(req, req.query.l);
  }
  res.locals.locale       = i18n.getLocale(req);
  res.locals.validLocales = validLocales;
  next();
});
if (environment !== "test") {
  app.use(csrf());
  app.use(function(req, res, next) {
    res.locals.csrfToken = req.csrfToken();
    next();
  });
  app.use(helmet.xframe("sameorigin"));
  app.use(helmet.hsts());
  app.use(helmet.xssFilter({setOnOldIE: true}));
  app.use(helmet.ienoopen());
  app.use(helmet.nosniff());
  app.use(helmet.nocache());
}
app.use(express.static(__dirname + '/public'));
app.use(connectAssets);
app.use(function(err, req, res, next) {
  if (err.status === 400) {
    res.statusCode = 404;
    res.render("errors/404");
  } else {
    console.error("503 - [" + req.method + "] " + req.originalUrl + " - ", err, " - ", JSON.stringify(req.headers), JSON.stringify(req.body));
    res.statusCode = 503;
    res.render("errors/500");
  }
});


// Routes
require('./routes/site')(app);
require('./routes/casino/lucky7')(app);


// Configuration
if (environment === "dev") {
  app.use(errorhandler({ dumpExceptions: true, showStack: true }));
};
if (environment === "production") {
  app.use(errorhandler());
}

var server = http.createServer(app);

require("./lib/sockets")(server, environment, sessionStore, cookieParser);

server.listen(app.get('port'), function(){
  console.log("Lucky7 is running on port %d in %s mode", app.get("port"), app.settings.env);
});
