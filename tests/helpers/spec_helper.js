var fs          = require('fs');
var environment = process.env.NODE_ENV || 'test';

require('date-utils');

if (!GLOBAL.appConfig) {
  GLOBAL.appConfig = require("./../../config/config");
}

module.exports.should = require("should");