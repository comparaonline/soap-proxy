autoScroll = true
socket     = io()

do ($ = jQuery) ->
  $.fn.goTo = ->
    $('html, body').animate scrollTop: "#{ $(this).offset().top }px", 'fast'
    this

  atBottom = ->
    scrollHeight = $(document).height()
    scrollPosition = $(window).height() + $(window).scrollTop()
    (scrollHeight - scrollPosition) / scrollHeight <= 0

  $(document).on 'scroll', -> autoScroll = atBottom()

  getHeaders = (headers) ->
    $dl = $('<dl class="headers">');
    for name, value of headers
      $dl.append $('<dt>').text name
      $dl.append $('<dd>').text value
    $dl

  showBody = ->
    $('<div>').append $('<a href="#">').text('Body').click (e) ->
      e.preventDefault()
      $($(this).parent()).next('.xml-body').toggle()

  addMessage = (id, type, data) ->
    $elem = $('#' + id)

    unless $elem.length
      $elem = $ '<li class="message">'
        .attr 'id', id
        .appendTo $ '#messages'

    $main = $ '<div>'
        .attr 'class', type
        .appendTo $elem

    switch type
      when 'incoming'
        $main
          .append getHeaders data.headers
          .append showBody()
          .append $('<pre class="xml-body">').text vkbeautify.xml data.body
      when 'outgoing'
        $main
          .append $('<div class="title">').text data.options.headers.soapaction
          .append getHeaders data.options.headers
          .append showBody()
          .append $('<pre class="xml-body">').text vkbeautify.xml data.body
    $main.goTo() if autoScroll

  socket.on 'incoming', (data) -> addMessage data.id, 'incoming', data
  socket.on 'outgoing', (data) -> addMessage data.id, 'outgoing', data

  # Status bar
  socket.on 'connect',           -> $('.status').text 'Connected'
  socket.on 'reconnect',         -> $('.status').text 'Reconnected'
  socket.on 'connect_error',     -> $('.status').text 'Connection error...'
  socket.on 'reconnect_attempt', -> $('.status').text 'Reconnecting...'
  socket.on 'reconnect_error',   -> $('.status').text 'Reconnection error...'
