program          = require 'commander'
http             = require 'http'
socketio         = require 'socket.io'
uuid             = require 'node-uuid'
express          = require 'express'
coffeeMiddleware = require 'coffee-middleware'

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

do createProxy = ->
  proxy = http.createServer (req, res) ->
    body = ''
    req.on 'data', (chunk) -> body += chunk
    req.on 'end', -> forward req, body, res

  forward = (req, body, res) ->
    id = uuid.v1()
    host = req.headers.host.split(':')
    options =
      hostname : host[0]
      port     : host[1] or 80
      method   : req.method
      path     : req.url
      headers  : req.headers

    io.emit 'outgoing', {id, options, body}
    req = http.request options, (response) ->
      responseBody = ''
      res.writeHead response.statusCode, response.headers
      response.pipe(res)
      response.on 'data', (chunk) -> responseBody += chunk
      response.on 'end', ->
        io.emit 'incoming',
          id      : id
          status  : response.statusCode
          headers : response.headers
          body    : responseBody
    req.write body if body
    req.on('error', (e) -> io.emit 'error', e)
    req.end()

  proxy.listen program.port
  console.log "Proxying port: #{ program.port }"