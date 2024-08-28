# frozen_string_literal: true

require 'websocket/driver'
require 'json'
require 'base64'
require 'socket'
require 'net/http'
require 'faye/websocket'
require 'uri'
require 'eventmachine'
require 'concurrent'

module Palapala
  CHROME_URL = 'http://localhost:9222'
end

class SynchronousRendering
  def initialize(debug: false)
    @debug = debug
    @header_html = '<div style="font-size: 9px; color: #333; padding: 0 10px;">Header</div>'
    @footer_html = '<div style="font-size: 9px; color: #333; padding: 0 10px;">Footer</div>'
    @socket_ready = Queue.new
    @pdf_ready_queue = Queue.new
  end

  def next_id
    @next_id ||= 1
    @next_id += 1
  end

  attr_writer :header_html, :footer_html

  attr_reader :debug

  def websocket
    @websocket ||= begin
      puts 'Opening new tab' # if debug
      uri = URI("#{Palapala::CHROME_URL}/json/new")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri)
      response = http.request(request)
      tab_info = JSON.parse(response.body)
      websocket_url = tab_info['webSocketDebuggerUrl']
      websocket = Faye::WebSocket::Client.new(websocket_url)
      puts "Connected to WebSocket URL: #{websocket_url}" if debug
      websocket
    end
  end

  def debug=(debug)
    puts 'Debug mode enabled' if debug
    @debug = debug
  end

  def start
    @event_thread = Thread.new do
      EventMachine.run do
        puts "websocket: #{websocket}" if debug
        websocket.on :message do |event|
          data = JSON.parse(event.data)
          puts "ON_MSG #{data['id']}: #{data}}" if debug && (data['id'].nil? || data['id'] < 10_000)
          # Network.loadingFinished
          # Page.frameStoppedLoading
          # Page.loadEventFired
          if data['method'] == 'Page.frameStoppedLoading' && @navigated
            @navigated = false
            puts 'Frame stopped loading, sending Page.printToPDF' if debug
            websocket.send(JSON.generate({
                                           id: 10_000 + next_id,
                                           method: 'Page.printToPDF',
                                           params: { printBackground: true,
                                                     marginTop: 3,
                                                     displayHeaderFooter: true,
                                                     headerTemplate: @header_html,
                                                     footerTemplate: @footer_html }
                                         }))
          end

          if data['id'] && data['id'] >= 10_000 && data['result']
            pdf_data = Base64.decode64(data['result']['data'])
            puts "PDF data received #{pdf_data[0..4]}" if debug
            @pdf_ready_queue.push(pdf_data)
          end
        end

        websocket.on :close do |_event|
          puts 'WebSocket closed' if debug
        end

        websocket.on :open do |_event|
          puts 'WebSocket opened' if debug
          # @websocket.send(JSON.generate({ id: next_id, method: "Network.enable" }))
          @websocket.send(JSON.generate({ id: next_id, method: 'Page.enable' }))
          yield(self) if block_given?
          @socket_ready.push(true)
        end
      end
    end
    @socket_ready.pop
  end

  def stop
    websocket.close
    EventMachine.stop
    @event_thread.join
  end

  def render(content)
    puts "Navigating to HTML content: #{content[0..64]}..." if debug
    encoded_content = Base64.strict_encode64(content)
    data_url = "data:text/html;base64,#{encoded_content}"
    websocket.send(JSON.generate({ id: next_id,
                                   method: 'Page.navigate',
                                   params: { url: data_url } }))
    @navigated = true
    puts 'HTML loaded (page navigate)' if debug
    # # Wait for the PDF to be ready
    @pdf_ready_queue.pop
  end
end

# read count from CLI params
count = (ARGV[0] || 10).to_i

require 'benchmark'
benchmark = Benchmark.measure do
  renderer = SynchronousRendering.new
  renderer.debug = false
  renderer.start
  (1..count).each do |i|
    hello_pdf = "<html><body><h1>Hello #{i}, PDF!</h1></body></html>"
    pdf_data = renderer.render(hello_pdf)
    File.binwrite("tmp/sync_#{i}.pdf", pdf_data)
    print('.')
  end
  renderer.stop
end

puts 'All work items processed'
puts "Count: #{count}"
puts "Time elapsed: #{benchmark.real} seconds"
sleep 0.1
