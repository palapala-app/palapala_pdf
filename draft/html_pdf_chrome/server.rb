# frozen_string_literal: true

require 'webrick'
require 'securerandom'

module HtmlPdfChrome
  class Server
    attr_reader :port

    CONTENT_TYPE = 'text/html' # "application/octet-stream"

    def initialize(port: nil)
      # Hash to store file data with their randomized URLs
      @files = {}
      @port = port

      @server = WEBrick::HTTPServer.new(Port: ENV.fetch('INTERNAL_SERVER_PORT', port || 9223))

      # Custom handler to serve files from memory
      @server.mount_proc '/file' do |req, res|
        file_key = req.path.sub('/file/', '')

        if @files.key?(file_key)
          res.status = 200
          res['Content-Type'] = CONTENT_TYPE
          res.body = @files[file_key]
        else
          res.status = 404
          res.body = 'File not found'
        end
      end
    end

    def start(wait: false)
      # check if server is running
      unless @server.status == :Running
        # Start the server in a new thread
        @server_thread = Thread.new { @server.start }
        trap('INT') do
          @server.shutdown
          @server_thread.join
        end
        if wait
          wait_for_server_status(:Running)
          puts "Server running at http://localhost:#{@port}, status: #{@server.status}"
        end
      end
      self
    end

    def url_for(key)
      URI.parse("http://localhost:#{@port}/file/#{key}")
    end

    def url_and_key_for(data)
      key = add_file(data)
      url = url_for(key)
      [url, key]
    end

    def stop(wait: false)
      @server.shutdown
      return unless wait

      wait_for_server_status(:Stop)
      puts 'Server stopped'
    end

    def wait_for_server_status(status)
      until @server.status == status
        puts "Server status: #{@server.status}"
        sleep 0.00000000001
      end
    end

    def add_file(data)
      key = SecureRandom.hex
      @files.store(key, data)
      key
    end

    def remove_file(key)
      @files.delete(key)
    end
  end
end
