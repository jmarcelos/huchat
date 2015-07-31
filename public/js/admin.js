// (function poll() {
//     $.ajax({
//         url: "/active_chats",
//         type: "GET",
//         success: function(data) {
//             console.log("polling");
//         },
//         dataType: "json",
//         complete: setTimeout(function() {poll()}, 5000),
//         timeout: 2000
//     })
// })();


$(function() {
    var websocket;
    console.log('admin loaded');

    $('body').on('click', '.list-group-item', function(){
        var chat_id = $(this).data('id');

        $('.chat-ext').removeClass('hidden');

        websocket = new WebSocket('ws://localhost:8080/bacon');
        
        websocket.onmessage = function (e) {
            create_message(e.data, 'server');
        };
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

        $('.hu-chat .log').append(new_msg).scrollTop(9999);
    };

    // sends message
    $('.hu-chat button').click(function(){
        var textarea = $('.hu-chat textarea');
        if (textarea.val() == '') return;
        var text = textarea.val();

        websocket.send(text);
        textarea.val('');
    });
});