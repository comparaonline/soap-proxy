program = require 'commander'
http    = require 'http'

program
  .version '0.0.1'
  .option '-p, --port [port]', 'Port to listen to', 8008
  .option '-H, --host [host]', 'Host to listen to', '0.0.0.0'
  .parse process.argv

host    = program.host

server = http.createServer (req, res) -> 
  body = ''
  req.on 'data', (chunk) -> body += chunk
  req.on 'end', -> 
    console.log '>>> Forwarding to external service...'
    forward req, body, res

forward = (req, body, res) ->
  console.log '-----------------------------'
  host = req.headers.host.split(':')
  options =
    hostname: host[0]
    port: host[1] or 80 
    method: req.method
    path: req.url
    headers: req.headers

  console.log 'Forwarding:'
  console.dir {options, body}
  req = http.request options, (response) ->
    responseBody = ''
    response.on 'data', (chunk) -> responseBody += chunk
    response.on 'end', ->
      console.log '<<< External service replied.'
      console.dir {status: response.statusCode, headers: response.headers, responseBody}
      console.log '-----------------------------'
      res.writeHead response.statusCode, response.headers
      res.end responseBody
  req.write body if body
  req.end()

server.listen program.port, program.host
console.log "http://#{program.host}:#{ program.port }"