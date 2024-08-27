# frozen_string_literal: true

require 'json'
require 'net/http'
require 'websocket/driver'

module Palapala
  # Render HTML content to PDF using Chrome in headless mode with minimal dependencies
  class Renderer
    def initialize
      # Create an instance of WebSocketClient with the WebSocket URL
      @client = Palapala::WebSocketClient.new(websocket_url)
      # Create the WebSocket driver
      @driver = WebSocket::Driver.client(@client)
      # Register the on_message callback
      @driver.on(:message, &method(:on_message))
      @driver.on(:close) { Thread.current[:renderer] = nil } # Reset the renderer on close
      # Start the WebSocket handshake
      @driver.start
      # Initialize the protocol to get the page events
      send_command_and_wait_for_result('Page.enable')
    end

    def self.thread_local_instance
      Thread.current[:renderer] ||= begin
        puts 'Creating new renderer' if Palapala.debug
        Renderer.new
      end
    end

    # Callback to handle the incomming WebSocket messages
    def on_message(e)
      puts "Received: #{e.data[0..64]}" if Palapala.debug
      @response = JSON.parse(e.data) # Parse the JSON response
    end

    # Update the current ID to the next ID (increment by 1)
    def next_id = @id = (@id || 0) + 1

    # Get the current ID
    def current_id = @id

    # Process the WebSocket messages until some state is true
    def process_until(&block)
      loop do
        @driver.parse(@client.read)
        return if block.call
        return if @driver.state == :closed
      end
    end

    # Method to send a message (text) and wait for a response
    def send_and_wait(message, &)
      puts "\nSending: #{message}" if Palapala.debug
      @driver.text(message)
      process_until(&)
    end

    # Method to send a CDP command and wait for some state to be true
    def send_command(method, params: {}, &block)
      send_and_wait(JSON.generate({ id: next_id, method:, params: }), &block)
    end

    # Method to send a CDP command and wait for the matching event to get the result
    # @return [Hash] The result of the command
    def send_command_and_wait_for_result(method, params: {})
      send_command(method, params:) do
        @response && @response['id'] == current_id
      end
      @response['result']
    end

    # Method to send a CDP command and wait for a specific method to be called
    def send_command_and_wait_for_event(method, event_name:, params: {})
      send_command(method, params:) do
        @response && @response['method'] == event_name
      end
    end

    # Convert HTML content to PDF
    # See https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF
    # @param html [String] The HTML content to convert to PDF
    # @param params [Hash] Additional parameters to pass to the CDP command
    def html_to_pdf(html, params: {})
      send_command_and_wait_for_event('Page.navigate', params: { url: data_url_for_html(html) },
                                                       event_name: 'Page.frameStoppedLoading')
      result = send_command_and_wait_for_result('Page.printToPDF', params:)
      Base64.decode64(result['data'])
    end

    def close
      @driver.close
      @client.close
    end

    private

    def data_url_for_html(html)
      "data:text/html;base64,#{Base64.strict_encode64(html)}"
    end

    # Open a new tab in the remote chrome and return the WebSocket URL
    def websocket_url
      ChromeProcess.spawn_chrome
      uri = URI("#{Palapala.headless_chrome_url}/json/new")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri)
      request['Content-Type'] = 'application/json'
      response = http.request(request)
      tab_info = JSON.parse(response.body)
      websocket_url = tab_info['webSocketDebuggerUrl']
      puts "WebSocket URL: #{websocket_url}" if Palapala.debug
      websocket_url
    end

    # Manage the Chrome child process
    module ChromeProcess
      def self.port_in_use?(port = 9222, host = '127.0.0.1')
        server = TCPServer.new(host, port)
        server.close
        false
      rescue Errno::EADDRINUSE
        true
      end

      def self.chrome_process_healthy?
        return false if @chrome_process_id.nil?

        begin
          Process.kill(0, @chrome_process_id) # Check if the process is alive
          true
        rescue Errno::ESRCH, Errno::EPERM
          false
        end
      end

      def self.kill_chrome
        return if @chrome_process_id.nil?

        Process.kill('KILL', @chrome_process_id) # Kill the process
        Process.wait(@chrome_process_id) # Wait for the process to finish
      end

      def self.chrome_path
        return Palapala.headless_chrome_path if Palapala.headless_chrome_path

        case RbConfig::CONFIG['host_os']
        when /darwin/
          '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        when /linux/
          '/usr/bin/google-chrome' # or "/usr/bin/chromium-browser"
        when /win|mingw|cygwin/
          "#{ENV.fetch('ProgramFiles(x86)', nil)}\\Google\\Chrome\\Application\\chrome.exe"
        else
          raise 'Unsupported OS'
        end
      end

      def self.spawn_chrome
        return if port_in_use?
        return if chrome_process_healthy?

        # Define the path and parameters separately
        # chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        params = ['--headless', '--disable-gpu', '--remote-debugging-port=9222']

        # Spawn the process with the path and parameters
        @chrome_process_id = Process.spawn(chrome_path, *params)

        # Wait until the port is in use
        sleep 0.1 until port_in_use?
        # Detach the process so it runs in the background
        Process.detach(@chrome_process_id)

        at_exit do
          if @chrome_process_id
            begin
              Process.kill('TERM', @chrome_process_id)
              Process.wait(@chrome_process_id)
              puts "Child process #{@chrome_process_id} terminated."
            rescue Errno::ESRCH
              puts "Child process #{@chrome_process_id} is already terminated."
            rescue Errno::ECHILD
              puts "No child process #{@chrome_process_id} found."
            end
          end
        end

        # Handle when the process is killed
        trap('SIGCHLD') do
          while (@chrome_process_id = Process.wait(-1, Process::WNOHANG))
            break if @chrome_process_id.nil?

            puts "Process #{@chrome_process_id} was killed."
            # Handle the error or restart the process if necessary
            @chrome_process_id = nil
          end
        rescue Errno::ECHILD
          @chrome_process_id = nil
        end
      end
    end
  end
end
