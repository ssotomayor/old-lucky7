session      = require "express-session"
environment  = process.env.NODE_ENV or "development"
SessionStore = if environment is "development" then require("connect-mongo")(session) else require("connect-dynamodb")({session: session})
options      = if environment is "development" then GLOBAL.appConfig().session.store else {client: GLOBAL.dynamodb, table: "sessions_" + environment}
exports      = module.exports = new SessionStore options