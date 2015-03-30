autoScroll = true
socket     = io()

do ($ = jQuery) ->
  $.fn.goTo = ->
    $('html, body').animate scrollTop: "#{ $(this).offset().top }px", 'fast'
    this
  $.fn.highlight = ->
    hljs.highlightBlock this[0] unless this.hasClass 'hljs'
    this

  atBottom = ->
    scrollHeight = $(document).height()
    scrollPosition = $(window).height() + $(window).scrollTop()
    (scrollHeight - scrollPosition) / scrollHeight <= 0

  $(document).on 'scroll', -> autoScroll = atBottom()

  getHeaders = (headers) ->
    $dl = $('<dl class="headers dl-horizontal">');
    for name, value of headers
      $dl.append $('<dt>').text name
      $dl.append $('<dd>').text value
    $dl

  showBody = (name) ->
    $('<div>').append $('<a href="#"="#" role="button" class="btn btn-primary">').text(name).click (e) ->
      e.preventDefault()
      $(this)
        .closest('.part')
        .find('.code-container')
        .toggle()
        .find('.xml-body')
        .highlight()

  download = (filename, text) ->
    pom = document.createElement 'a'
    pom.setAttribute 'href', 'data:text/plain;charset=utf-8,' + encodeURIComponent text
    pom.setAttribute 'download', filename
    pom.style.display = 'none';
    document.body.appendChild pom
    pom.click()
    document.body.removeChild pom

  addMessage = (id, type, data) ->
    $elem = $("##{id}")

    unless $elem.length
      $elem = $('<div class="message panel panel-default">').attr('id', id).appendTo $('#messages')
      $elem.append $('<div class="panel-heading">').append $('<h1 class="panel-title">')
      $panel_body = $('<div class="panel-body">').appendTo $elem
      $container = $('<div class="container-fluid">').appendTo $panel_body
      $ '<div class="row">'
        .append $('<div class="part col-xs-6 outgoing">').append $('<h2>').text 'Request'
        .append $('<div class="part col-xs-6 incoming">').append $('<h2>').text 'Response'
        .appendTo $container
      $ '<div class="row headers">'
        .append $('<div class="part col-xs-6 outgoing">')
        .append $('<div class="part col-xs-6 incoming">')
        .appendTo $container
      $ '<div class="row body">'
        .append $('<div class="part col-xs-6 outgoing">').append showBody('View request body')
        .append $('<div class="part col-xs-6 incoming">').append showBody('View response body')
        .appendTo $container

    title = data.options.headers.soapaction.replace(/(^")|("$)/gi, '') if type is 'outgoing'
    $elem.find('h1').text title if title
    headers = if type == 'incoming' then data.headers else data.options.headers
    $elem.find(".headers > .#{type}").append getHeaders headers
    $code_container = $('<div class="well code-container">').hide()
    $code = $('<pre class="xml xml-body">').text vkbeautify.xml _.unescape data.body
    $download_link = $('<a href="#" role="button" class="btn btn-default">Download</a>')
    $download_link.click (e) ->
        e.preventDefault()
        download "#{$elem.find('h1').text()}.xml", vkbeautify.xml _.unescape data.body

    $code_container.append [$code, $download_link]
    $elem.find(".body > .#{type}").append $code_container
    $elem.goTo() if autoScroll

  socket.on 'incoming', (data) -> addMessage data.id, 'incoming', data
  socket.on 'outgoing', (data) -> addMessage data.id, 'outgoing', data

  change_status = (text, css) ->
    $('.status').text text
    $('.status').parent()
        .removeClass('bg-warning')
        .removeClass('bg-success')
        .removeClass('bg-danger')
        .addClass(css)
  ok = (text) -> change_status text, 'bg-success'
  warning = (text) -> change_status text, 'bg-warning'
  danger = (text) -> change_status text, 'bg-danger'

  # Status bar
  socket.on 'connect',           -> $ -> ok "Connected"
  socket.on 'reconnect',         -> $ -> ok 'Reconnected'
  socket.on 'connect_error',     -> $ -> warning 'Connection error...'
  socket.on 'reconnect_attempt', -> $ -> warning 'Reconnecting...'
  socket.on 'reconnect_error',   -> $ -> danger 'Reconnection error...'
