# frozen_string_literal: true

require 'uri'
require 'socket'

module Palapala
  # Create a socket wrapper that conforms to what the websocket-driver expects
  class WebSocketClient
    attr_reader :url

    def initialize(url)
      @url = url
      uri = URI.parse(url)
      @socket = TCPSocket.new(uri.host, uri.port)
    end

    def write(data)
      @socket.write(data)
    end

    def read
      @socket.readpartial(1024)
    end

    def close
      @socket.close
    end
  end
end
