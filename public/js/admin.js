(function poll() {
    $.ajax({
        url: "/active_chats",
        type: "GET",
        success: function(data) {
            console.log("polling");
        },
        dataType: "json",
        complete: setTimeout(function() {poll()}, 5000),
        timeout: 2000
    })
})();