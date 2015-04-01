EventEmitter = require('events').EventEmitter
http         = require 'http'
uuid         = require 'node-uuid'

getStreamContent = (stream, callback) ->
  content = ''
  stream.on 'data', (chunk) -> content += chunk
  stream.on 'end', -> callback content

module.exports = class Proxy extends EventEmitter
  constructor: (@port) ->
    @server = http.createServer (clientRequest, responseForClient) =>
      getStreamContent clientRequest, (body) => @handleRequest clientRequest, body, responseForClient

  start: ->
    @server.listen @port
    @emit 'log', info: "Proxying port: #{ @port }"

  forward: (serviceResponse, responseForClient) ->
    responseForClient.writeHead serviceResponse.statusCode, serviceResponse.headers
    serviceResponse.pipe responseForClient

  generateId: -> uuid.v1()
  getOptions: (request) ->
    host = request.headers.host.split(':')
    options =
      hostname : host[0]
      port     : host[1] or 80
      method   : request.method
      path     : request.url
      headers  : request.headers

  handleResponse: (response, body, id) ->
    headers = response.headers
    status = response.statusCode
    @emit 'response', id, headers, body, status

  handleRequest: (clientRequest, body, responseForClient) ->
    id = @generateId()
    options = @getOptions clientRequest
    @emit 'request', id, options.headers, body
    serviceRequest = http.request options, (serviceResponse) =>
      @forward serviceResponse, responseForClient
      getStreamContent serviceResponse, (body) => @handleResponse serviceResponse, body, id
    serviceRequest.write body if body
    serviceRequest.on 'error', (e) => @emit 'error', e
    serviceRequest.on 'error', (e) => @emit 'log', error: (e.message ? e.toString())
    serviceRequest.end()