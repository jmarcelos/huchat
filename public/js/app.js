$(function() {
	var	websocket;
	var opts = {
		title: 'Atendimento online',
		label: 'Olá Viajante! Em que posso te ajudar?',
		privacy: 'Fale com um <a href="#" class="start-webchat">consultor</a> agora.',
		small: 'Essa conversa será gravada para controle.',
		websocket: false,
		websocket_endpoint: 'ws://localhost:8080',
		elasticsearch_endpoint: '/busca'
	}

	$(window).on("hu-chat-active", function() {
  	console.log('chat opened');
	});

	$(window).on("hu-chat-online", function() {
		websocket = new WebSocket(opts.websocket_endpoint);
		
		websocket.onmessage = function (e) {
			create_message(e.data, 'system');
		};
		opts.websocket = true;
	});

	$(window).on("hu-chat-inactive", function() {
  	console.log('chat closed');
  	$('.huchat .log ul li').remove();

  	if (opts.websocket) {
	  	opts.websocket = false;
	  	websocket.close();
  	}
	});

	var _d = function(f) {
		if (f.toString().length == 1)
			f = "0" + f
		
		return f
	}

	// timestamp message
	var get_date = function(){
		var t = new Date();
		return _d(t.getHours()) +':'+_d(t.getMinutes()) +':'+_d(t.getSeconds());
	}

	// creats li message
	var create_message = function(data, autor) {
		console.log('creates message', data);
		var message = data.replace(/\n/g,'<br>').replace(/&/g,'e');

		var messages_box = $('.huchat .log ul');
		var new_msg = '<li class="'+autor+'"><span>' + get_date() + '</span> : ' + message + '</li>';

		messages_box.append(new_msg).scrollTop(9999);
	};

	var html = '<span class="title">'
		+	'<i class="glyphicon glyphicon-user"></i> ' + opts.title + ' </span>'
   	+ '<div class="content"><p>' + opts.label + '</p>'
		+ '<div class="log"><ul></ul></div>'
   	+ '<textarea rows="3" cols="35" placeholder="Escreva sua dúvida"></textarea>'
	  + '<button type="button">enviar</button>'
	  + '<small>' + opts.privacy + '</small></div>';

	$('<div/>', {
    'class':'huchat',
    'html': html
	}).appendTo('body');

	// activate and desactivate chat
	$('.huchat .title').click(function(){
		var huchat = $(".huchat");

		if (huchat.hasClass("active")) {
			$(window).trigger("hu-chat-inactive");
			huchat.toggleClass('active');
		} else {
			$(window).trigger("hu-chat-active");
			huchat.addClass('active');
		}		
	});

	// sends message
	// TODO: ajax [fail/waiting]
	$('.huchat button').click(function(){
		var textarea = $('.huchat textarea');
		if (textarea.val() == '') return;
		var text = textarea.val();

		// todo: fallback for older browsers, long pooling...
		if (opts.websocket) {
			websocket.send(text);
		} else {
			create_message(text, 'client');

			$.ajax({
			  url: opts.elasticsearch_endpoint,
			  method: "POST",
			  cache: false,
			  data: text,
			  dataType: 'json',
			  complete: function(result){
			  	// console.log(result);
			  },
			  success: function(result){
			  	create_message(result.resposta.answer, 'server');
			  },
			});
		}

		textarea.val('');
	});

	$('.start-webchat').click(function(){
		$(window).trigger("hu-chat-online");

		$('.huchat small').text(opts.small);
		return false;
	});
});