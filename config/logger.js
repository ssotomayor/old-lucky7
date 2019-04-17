(function() {
  var consoleError, consoleLog, fs;

  fs = require("fs");

  consoleLog = console.log;

  consoleError = console.error;

  console.log = function() {
    var args;
    args = arguments;
    if (args[0]) {
      args[0] = "" + (new Date().toGMTString()) + " - log: " + args[0];
    }
    return consoleLog.apply(void 0, args);
  };

  console.error = function() {
    var args;
    args = arguments;
    if (args[0]) {
      args[0] = "" + (new Date().toGMTString()) + " - error: " + args[0];
    }
    return consoleError.apply(void 0, args);
  };

  console.errorToFile = function() {
    var arg, args, dump, _i, _len;
    args = arguments;
    if (args[0]) {
      args[0] = "" + (new Date().toGMTString()) + " - log: " + args[0];
    }
    dump = "";
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      dump += typeof arg === "object" ? JSON.stringify(arg) : arg;
      dump += " ";
    }
    return fs.appendFile("errors.dump", "" + dump + "\r\n");
  };

  console.logToFile = function() {
    var arg, args, dump, _i, _len;
    args = arguments;
    if (args[0]) {
      args[0] = "" + (new Date().toGMTString()) + " - log: " + args[0];
    }
    dump = "";
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      dump += typeof arg === "object" ? JSON.stringify(arg) : arg;
      dump += " ";
    }
    return fs.appendFile("logs.dump", "" + dump + "\r\n");
  };

  process.on("uncaughtException", function(err) {
    console.error("Uncaught exception, exiting...", err.stack);
    return process.exit();
  });

}).call(this);
