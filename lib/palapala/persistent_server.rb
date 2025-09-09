require 'webrick'
require 'securerandom'
require 'socket'

module Palapala
  # Persistent server that stays running and serves HTML content from memory
  # Eliminates the overhead of creating/destroying servers for each PDF
  class PersistentServer
    @@instance = nil
    @@files = {}
    @@mutex = Mutex.new

    def self.instance
      @@mutex.synchronize do
        @@instance ||= new
      end
    end

    def initialize(port: 9223)
      puts "initializing persistent server" if defined?(Palapala) && Palapala.debug
      @port = find_available_port(port)
      @server = WEBrick::HTTPServer.new(
        Port: @port,
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )

      # Custom handler to serve files from memory
      @server.mount_proc '/file' do |req, res|
        file_key = req.path.sub('/file/', '')

        @@mutex.synchronize do
          if @@files.key?(file_key)
            res.status = 200
            res['Content-Type'] = 'text/html'
            res.body = @@files[file_key]
          else
            res.status = 404
            res.body = 'File not found'
          end
        end
      end

      # Start server in background thread
      @thread = Thread.new { @server.start }

      # Wait for server to be ready
      sleep 0.05 until @server.status == :Running
      puts "initializing persistent server: DONE" if defined?(Palapala) && Palapala.debug
    end

    # Serve HTML content and return URL
    def serve_html(html)
      puts "PersistentServer: Serving HTML content (#{html.bytesize} bytes)" if defined?(Palapala) && Palapala.debug
      key = SecureRandom.hex
      @@mutex.synchronize do
        @@files[key] = html
        puts "PersistentServer: Stored content with key #{key}" if defined?(Palapala) && Palapala.debug
      end
      url = "http://localhost:#{@port}/file/#{key}"
      puts "PersistentServer: Returning URL #{url}" if defined?(Palapala) && Palapala.debug
      url
    end

    # Clean up served content
    def cleanup(key)
      @@mutex.synchronize do
        @@files.delete(key)
      end
    end

    # Get current port
    def port
      @port
    end

    # Check if server is running
    def running?
      @server.status == :Running
    end

    # Stop the server
    def stop
      @server.shutdown
      @thread.join
    end

    private

    # Find an available port starting from the preferred port
    def find_available_port(preferred_port)
      port = preferred_port
      loop do
        begin
          server = TCPServer.new(port)
          server.close
          return port
        rescue Errno::EADDRINUSE
          port += 1
          # Prevent infinite loop - if we can't find a port within 100 attempts, raise
          raise "Could not find available port starting from #{preferred_port}" if port > preferred_port + 100
        end
      end
    end
  end
end
