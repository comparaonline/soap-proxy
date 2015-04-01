http             = require 'http'
socketio         = require 'socket.io'
express          = require 'express'
coffeeMiddleware = require 'coffee-middleware'
EventEmitter     = require('events').EventEmitter

module.exports = class WebUI extends EventEmitter
  constructor: (@port) ->
    app = express()
    @server = http.Server(app)
    @io = socketio @server
    app.use coffeeMiddleware src: "#{ __dirname }", compress: true
    app.use '/public', express.static "#{ __dirname }/public"
    app.get '/', (req, res) -> res.sendFile __dirname + '/webui.html'

  send: (name, args...) -> @io.emit name, args...
  start: -> @server.listen @port, => @emit 'log', info: "WebUI on port: #{@port}"