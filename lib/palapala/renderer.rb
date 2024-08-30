require "json"
require "net/http"
require "websocket/driver"
require_relative "./web_socket_client"
require_relative "./chrome_process"

module Palapala
  # Render HTML content to PDF using Chrome in headless mode with minimal dependencies
  class Renderer
    def initialize
      puts "Initializing a renderer" if Palapala.debug
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
      send_command_and_wait_for_result("Page.enable")
    end

    def websocket_url
      self.class.websocket_url
    rescue Errno::ECONNREFUSED
      ChromeProcess.spawn_chrome # Spawn a new Chrome process
      self.class.websocket_url # Retry (once)
    end

    # Create a thread-local instance of the renderer
    def self.thread_local_instance
      Thread.current[:renderer] ||= Renderer.new
    end

    # Reset the thread-local instance of the renderer
    def self.reset
      puts "Clearing the thread local renderer" if Palapala.debug
      Thread.current[:renderer] = nil
    end

    # Callback to handle the incomming WebSocket messages
    def on_message(e)
      puts "Received: #{e.data[0..64]}" if Palapala.debug
      @response = JSON.parse(e.data) # Parse the JSON response
      if @response["error"] # Raise an error if the response contains an error
        raise "#{@response["error"]["message"]}: #{@response["error"]["data"]} (#{@response["error"]["code"]})"
      end
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
        @response && @response["id"] == current_id
      end
      @response["result"]
    end

    # Method to send a CDP command and wait for a specific method to be called
    def send_command_and_wait_for_event(method, event_name:, params: {})
      send_command(method, params:) do
        @response && @response["method"] == event_name
      end
    end

    # Convert HTML content to PDF
    # See https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF
    # @param html [String] The HTML content to convert to PDF
    # @param params [Hash] Additional parameters to pass to the CDP command
    def html_to_pdf(html, params: {})
      send_command_and_wait_for_event("Page.navigate", params: { url: data_url_for_html(html) },
                                                       event_name: "Page.frameStoppedLoading")
      result = send_command_and_wait_for_result("Page.printToPDF", params:)
      Base64.decode64(result["data"])
    end

    def self.html_to_pdf(html, params: {})
      thread_local_instance.html_to_pdf(html, params: params)
    end

    def close
      @driver.close
      @client.close
    end

    # Open a new tab in the remote chrome and return the WebSocket URL
    def self.websocket_url
      uri = URI("#{Palapala.headless_chrome_url}/json/new")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri)
      request["Content-Type"] = "application/json"
      response = http.request(request)
      tab_info = JSON.parse(response.body)
      websocket_url = tab_info["webSocketDebuggerUrl"]
      puts "WebSocket URL: #{websocket_url}" if Palapala.debug
      websocket_url
    end

    private

    # Convert the HTML content to a data URL
    def data_url_for_html(html)
      "data:text/html;base64,#{Base64.strict_encode64(html)}"
    end
  end
end
