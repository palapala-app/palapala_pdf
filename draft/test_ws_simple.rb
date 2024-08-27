# frozen_string_literal: true

require 'websocket-client-simple'
require 'json'
require 'base64'
require 'net/http'
require 'uri'

module Palapala
  CHROME_URL = 'http://localhost:9222'
end

class SynchronousRendering
  def initialize(debug: false)
    @debug = debug
    @header_html = '<div style="font-size: 9px; color: #333; padding: 0 10px;">Header</div>'
    @footer_html = '<div style="font-size: 9px; color: #333; padding: 0 10px;">Footer</div>'
    @pdf_ready_queue = Queue.new
    start
  end

  def next_id
    @next_id ||= 1
    @next_id += 1
  end

  attr_accessor :header_html, :footer_html, :debug, :navigated, :socket_ready, :pdf_ready_queue, :pdf_data

  def websocket
    debug = self.debug

    @websocket ||= begin
      puts 'Opening new tab' if debug
      uri = URI("#{Palapala::CHROME_URL}/json/new")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Put.new(uri)
      response = http.request(request)
      tab_info = JSON.parse(response.body)
      websocket_url = tab_info['webSocketDebuggerUrl']
      ws = WebSocket::Client::Simple.connect(websocket_url)

      outervar = self

      ws.on :message do |msg|
        data = JSON.parse(msg.data)
        puts "ON_MSG #{data['id']}: #{data}" if debug && (data['id'].nil? || data['id'] < 10_000)

        if data['method'] == 'Page.frameStoppedLoading' && outervar.navigated
          outervar.navigated = false
          puts 'Frame stopped loading, sending Page.printToPDF' if debug
          ws.send(JSON.generate({
                                  id: 10_000 + outervar.next_id,
                                  method: 'Page.printToPDF',
                                  params: {
                                    printBackground: true,
                                    marginTop: 3,
                                    displayHeaderFooter: true,
                                    headerTemplate: outervar.header_html,
                                    footerTemplate: outervar.footer_html
                                  }
                                }))
        end

        if data['id'] && data['id'] >= 10_000 && data['result']
          pdf_data = Base64.decode64(data['result']['data'])
          puts "PDF data received #{pdf_data[0..4]}" if debug
          outervar.pdf_ready_queue.push(pdf_data)
          # outervar.pdf_data = pdf_data
        end
      end

      ws.on :open do
        puts "WebSocket opened *#{outervar}*" if debug
        ws.send(JSON.generate({ id: outervar.next_id, method: 'Page.enable' }))
        puts 'Sent Page.enable command' if debug
        outervar.socket_ready = true
      end

      ws.on :close do |_e|
        puts 'WebSocket closed' if debug
        outervar.socket_ready = false
      end

      ws.on :error do |e|
        puts "WebSocket error: #{e.message}" if debug
      end

      ws
    end
  end

  def start
    Thread.new do
      websocket
    end
    puts 'waiting for socket to be ready' if debug
    sleep 0.1 until socket_ready
    puts 'socket is ready' if debug
  end

  def stop
    websocket.close
  end

  def render(content)
    self.pdf_data = nil
    puts "Navigating to HTML content: #{content[0..64]}..." if debug
    encoded_content = Base64.strict_encode64(content)
    data_url = "data:text/html;base64,#{encoded_content}"
    websocket.send(JSON.generate({ id: next_id, method: 'Page.navigate', params: { url: data_url } }))
    @navigated = true
    puts 'HTML loaded (page navigate)' if debug
    # loop do
    #   break if pdf_data
    #   sleep 0.001 # This prevents a busy-wait loop that would consume CPU unnecessarily
    # end
    # pdf_data
    pdf_ready_queue.pop
  end
end

# read count from CLI params
count = (ARGV[0] || 10).to_i
stages = (ARGV[1] || 1).to_i
debug = (ARGV[2] == 'debug')

require 'benchmark'
benchmark = Benchmark.measure do
  (1..stages).each do |s|
    renderer = SynchronousRendering.new(debug:)
    puts "\nSTAGE #{s}"
    (1..count).each do |i|
      hello_pdf = "<html><body><h1>Hello #{i}, PDF!</h1></body></html>"
      pdf_data = renderer.render(hello_pdf)
      File.binwrite("tmp/sync_#{i}.pdf", pdf_data)
      print('.')
    end
    renderer.stop
  end
  # sleep 0.5
end

puts
puts 'All work items processed'
puts "Count: #{count}"
puts "Time elapsed: #{benchmark.real} seconds"
sleep 0.1
