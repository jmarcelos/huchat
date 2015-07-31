$(function() {
	var	websocket;
	var opts = {
		title: 'Atendimento online',
		label: 'Olá Viajante! Em que posso te ajudar?',
		privacy: 'Fale com um <a href="#" class="start-webchat">consultor</a> agora.',
		small: 'Essa conversa será gravada para controle.',
		websocket: false,
		websocket_endpoint: 'ws://localhost:8080/bacon',
		elasticsearch_endpoint: '/busca',
		elastisearch_error: 'Ops, nosso robô está viajando.<br> Por favor, <a href="#" class="start-webchat">fale com um consultor</a> ou tente mais tarde.'
	}

	$(window).on("hu-chat-active", function() {
  	console.log('chat opened');
	});

	$(window).on("hu-chat-online", function() {
		websocket = new WebSocket(opts.websocket_endpoint);
		
		websocket.onmessage = function (e) {
			create_message(e.data, 'server');
		};
		opts.websocket = true;
		$('.huchat small').text(opts.small);
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
		var new_msg = '<li class="'+autor+'"><span>' + get_date() + '</span> ' + message + '</li>';

		$('.huchat .log ul').append(new_msg).scrollTop(9999);
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
	$('.huchat button').click(function(){
		var textarea = $('.huchat textarea');
		if (textarea.val() == '') return;
		var text = textarea.val();

		// todo: fallback older browsers, long pooling...
		if (opts.websocket) {
			websocket.send(text);
		} else {
			create_message(text, 'client');

			$.ajax({
			  url: opts.elasticsearch_endpoint + "/" + text,
			  method: "GET",
			  dataType: 'json',
			  success: function(result){
			  	var r = JSON.parse(result);

			  	create_message(r.response.answer, 'server');

			  	if (r.redirecionar_chat) {
			  		console.log(">>>>>>", r);
						$(window).trigger("hu-chat-online");	
			  	}
			  },
			  error: function(result){
			  	create_message(opts.elastisearch_error, 'server');
			  }
			});
		}

		textarea.val('');
	});

	$('.huchat').on('click', '.start-webchat', function(){
		$(window).trigger("hu-chat-online");
		return false;
	});
});