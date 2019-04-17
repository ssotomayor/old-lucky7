fs = require "fs"

consoleLog   = console.log
consoleError = console.error

console.log         = ()->
  args = arguments
  args[0] = "#{new Date().toGMTString()} - log: #{args[0]}"  if args[0]
  consoleLog.apply undefined, args

console.error       = ()->
  args = arguments
  args[0] = "#{new Date().toGMTString()} - error: #{args[0]}"  if args[0]
  consoleError.apply undefined, args

console.errorToFile = ()->
  args = arguments
  args[0] = "#{new Date().toGMTString()} - log: #{args[0]}"  if args[0]
  dump = ""
  for arg in args
    dump += if typeof arg is "object" then JSON.stringify(arg) else arg
    dump += " "
  fs.appendFile "errors.dump", "#{dump}\r\n"

console.logToFile   = ()->
  args = arguments
  args[0] = "#{new Date().toGMTString()} - log: #{args[0]}"  if args[0]
  dump = ""
  for arg in args
    dump += if typeof arg is "object" then JSON.stringify(arg) else arg
    dump += " "
  fs.appendFile "logs.dump", "#{dump}\r\n"

process.on "uncaughtException", (err)->
  console.error "Uncaught exception, exiting...", err.stack
  process.exit()