program          = require 'commander'
http             = require 'http'
socketio         = require 'socket.io'
express          = require 'express'
coffeeMiddleware = require 'coffee-middleware'
Proxy            = require './proxy'

program
  .version '0.0.1'
  .option '-p, --port [port]', 'Port to listen to [8008]', 8008
  .option '-w, --web [webport]', 'Port to listen for WebUI [8000]', 8000
  .parse process.argv

io  = null
do createServer = ->
  app = express()
  server = http.Server(app)
  io = socketio server

  app.use coffeeMiddleware src: "#{ __dirname }", compress: true
  app.use '/public', express.static "#{ __dirname }/public"
  app.get '/', (req, res) -> res.sendFile __dirname + '/webui.html'

  server.listen program.web, -> console.log "WebUI on port: #{program.web}"


proxy = new Proxy(program.port)

proxy.on 'log', (log) ->
  console.log "[#{severity.toUpperCase()}] #{message}" for severity, message of log
proxy.on 'error', (e) -> io.emit 'error', e
proxy.on 'error', (e) -> console.error "[ERROR] #{e}"
proxy.on 'request', (id, headers, body, status) -> io.emit 'request', {id, headers, body, status}
proxy.on 'response', (id, headers, body) -> io.emit 'response', {id, headers, body}

proxy.start()