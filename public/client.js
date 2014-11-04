var autoScroll = true;
var socket = io();

(function($) {
  $.fn.goTo = function() {
    $('html, body').animate({
      scrollTop: $(this).offset().top + 'px'
    }, 'fast');
    return this; // for chaining...
  }

  function scrolledBottom() {
    var scrollHeight = $(document).height();
    var scrollPosition = $(window).height() + $(window).scrollTop();
    return ((scrollHeight - scrollPosition) / scrollHeight <= 0);
  }

  $(document).on('scroll', function () {
    autoScroll = scrolledBottom();
  })

  function getHeaders(headers) {
    var i, $ul;

    $table = $('<table class="headers">');
    for (i in headers) {
      $table.append(
        $('<tr>')
          .append($('<td>').append($('<strong>').text(i)))
          .append($('<td>').text(headers[i]))
      );
    }
    return $table;
  }

  function showBody() {
    return $('<div>').append(
      $('<a href="#">').text('Body').click(function (e) {
        e.preventDefault();
        $($(this).parent()).next('.xml-body').toggle();
      })
    );
  }
  function addMessage(id, type, data) {
    var $elem = $('#' + id), $main;
    if (!$elem.length) {
      $elem = $('<li class="message">')
        .attr('id', id)
        .appendTo($('#messages'));
    }
    $main = $('<div>')
        .attr('class', type)
        .appendTo($elem);

    switch (type) {
      case 'incoming':
        $main
          .append(getHeaders(data.headers))
          .append(showBody())
          .append($('<pre class="xml-body">').text(vkbeautify.xml(data.body)));
        break;
      case 'outgoing':
        $main
          .append($('<div class="title">').text(data.options.headers.soapaction))
          .append(getHeaders(data.options.headers))
          .append(showBody())
          .append($('<pre class="xml-body">').text(vkbeautify.xml(data.body)));
        break;
    }
    if (autoScroll) {
      $main.goTo();
    }
  }

  socket.on('connect', function () {
    $('.status').text('Connected');
  });
  socket.on('reconnect', function () {
    $('.status').text('Reconnected');
  });
  socket.on('connect_error', function () {
    $('.status').text('Connection error...');
  });
  socket.on('reconnect_attempt', function () {
    $('.status').text('Reconnecting...');
  });
  socket.on('reconnect_error', function () {
    $('.status').text('Reconnection error...');
  });
  socket.on('incoming', function (data) {
    addMessage(data.id, 'incoming', data);
  });
  socket.on('outgoing', function (data) {
    addMessage(data.id, 'outgoing', data);
  });
})(jQuery);