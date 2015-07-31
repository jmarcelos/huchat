#!/usr/bin/env ruby

require 'em-websocket'
require 'em-hiredis'
require 'logger'
require 'redis'

require_relative 'conf'

redis = Redis.new(url: REDIS_ENDOINT)
redis.set 'active', 0

puts 'Starting WebSockets at port 8080...'

EM.run do
  @log = Logger.new(STDOUT)
  @channel = ''

  EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do |handshake|
      @log.info handshake
      
      if handshake
        @log.info handshake.path
      end

      @redis = EM::Hiredis.connect(REDIS_ENDOINT)
      @redis.incr 'active'

      # todo: use uniq value in chat identifier
      @channel = "chat_#{handshake.path}"
      pubsub = @redis.pubsub
      pubsub.subscribe(@channel)

      @log.info "WebSocket connection opened; chat room: #{@channel}"

      pubsub.on(:message) do |channel, message|
        @log.debug "redis pubsub.on(:message); channel: #{channel}; message: #{message}"
        ws.send(message)
      end
    end

    # event: web socket close
    ws.onclose do
      @log.info "WebSocket connection closed"
      @redis.decr 'active'
    end

    # event: web socket received message
    ws.onmessage do |message|
      @log.debug "ws.onmessage; message: #{message}"

      begin
        @redis.publish(@channel, message)
      rescue => e
        @log.error e
      end
    end
  end
end