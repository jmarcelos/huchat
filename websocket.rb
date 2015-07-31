#!/usr/bin/env ruby

require 'em-websocket'
require 'em-hiredis'
require 'json'
require 'logger'
require 'redis'

redis = Redis.new(:url => "redis://x:ADOTFQVEAZDEYDVU@aws-us-east-1-portal.6.dblayer.com:10185/")
redis.set 'active', 0



# helper module to do some parsing and cleaning
module ChatServer
  extend self

  DEFAULT_CHAT_ROOM = 'default'
  DEFAULT_USER_NAME = 'anonymous'
  DEFAULT_MESSAGE = ':)'
  VALID_MESSAGE_KEYS = ['user_name', 'chat_room', 'message']

  # clean chat room name
  def chat_room_name(data)
    return DEFAULT_CHAT_ROOM if data.nil? || !data.respond_to?(:gsub)
    chat_room_name = data.gsub(/\W/,'')
    return DEFAULT_CHAT_ROOM if chat_room_name.nil? || chat_room_name.empty?
    chat_room_name
  end

  # clean user name
  def user_name(data)
    return DEFAULT_USER_NAME if data.nil? || !data.respond_to?(:gsub)
    user_name = data.gsub(/[^\w\ ]/, '')
    return DEFAULT_USER_NAME if user_name.nil? || user_name.empty?
    user_name
  end

  # strip tags from a message
  def clean_message(message)
    return DEFAULT_MESSAGE if message.nil? || !message.respond_to?(:gsub)
    return message.gsub(/<(?:.|\n)*?>/, '')
  end

  # parse JSON message and clean data
  def message_string_to_object(message_string)

    begin
      data = JSON.parse message_string
    rescue => e
      data = {}
    end

    # remove invalid keys
    data.delete_if {|key,value| !VALID_MESSAGE_KEYS.include?(key) }

    # clean data
    data['message'] = clean_message data['message']
    data['chat_room'] = chat_room_name data['chat_room']
    data['user_name'] = user_name data['user_name']

    data
  end

end

EM.run do
  @log = Logger.new(STDOUT)

  EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen do |handshake|
      @log.info handshake
      
      if handshake
        @log.info handshake.headers["User-Agent"]
      end

      chat_room_name = ChatServer.chat_room_name handshake.path

      @log.info "WebSocket connection opened; chat room: #{chat_room_name}"

      @redis = EM::Hiredis.connect("redis://x:ADOTFQVEAZDEYDVU@aws-us-east-1-portal.6.dblayer.com:10185/")
      @redis.incr 'active'

      pubsub = @redis.pubsub
      pubsub.subscribe chat_room_name
      pubsub.on(:message) do |channel, message|
        @log.debug "redis pubsub.on(:message); channel: #{channel}; message: #{message}"
        # ChatServer.message_string_to_object(message).to_json
        ws.send message
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
        data = ChatServer.message_string_to_object message
        @redis.publish data['chat_room'], message
      rescue => e
        @log.error e
      end

    end

  end

end