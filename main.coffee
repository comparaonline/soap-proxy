program = require 'commander'
Proxy   = require './proxy'
WebUI   = require './web_ui'

program
  .version '0.0.1'
  .option '-p, --port [port]', 'Port to listen to [8008]', 8008
  .option '-w, --web [webport]', 'Port to listen for WebUI [8000]', 8000
  .parse process.argv

log = (severity, message) -> console.log "[#{severity.toUpperCase()}] #{message}"
handleLogs = (emitter) -> emitter.on 'log', (params) ->
  log severity, message for severity, message of params

webUI = new WebUI(program.web)
proxy = new Proxy(program.port)

proxy.on 'error', (e) -> webUI.send 'error', e
proxy.on 'request', (id, headers, body, status) -> webUI.send 'request', {id, headers, body, status}
proxy.on 'response', (id, headers, body) -> webUI.send 'response', {id, headers, body}

handleLogs proxy
handleLogs webUI

webUI.start()
proxy.start()