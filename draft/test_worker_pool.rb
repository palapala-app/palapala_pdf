# frozen_string_literal: true

require 'websocket/driver'
require 'json'
require 'base64'
require 'socket'
require 'net/http'
require 'faye/websocket'
require 'eventmachine'
require 'uri'
require 'concurrent'

module Palapala
  CHROME_URL = 'http://localhost:9222'
end

WorkItem = Struct.new(:body_html, :header_html, :footer_html, :data, :callback)

class WorkerPool
  def initialize(debug: false)
    @debug = debug
    @queue = Queue.new
  end

  def start(worker_count = 2)
    puts 'Started EventMachine' if @debug
    EM.run do
      @threads = worker_count.times.map do |i|
        thread_id = "t#{i}"
        Thread.new do
          puts "Starting thread #{thread_id}" if @debug
          open_websocket(thread_id) do |websocket|
            process_next_work_item(websocket, thread_id)
          end
        end
      end
    end
  end

  def join
    @threads.each(&:join)
  end

  def stop
    @threads.each(&:exit)
  end

  def add_work(work_item)
    @queue.push(work_item)
  end

  private

  def next_id
    Thread.current[:id] ||= 1
    Thread.current[:id] += 1
  end

  def open_websocket(thread_id)
    uri = URI("#{Palapala::CHROME_URL}/json/new")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri)
    response = http.request(request)
    tab_info = JSON.parse(response.body)
    websocket_url = tab_info['webSocketDebuggerUrl']

    websocket = Faye::WebSocket::Client.new(websocket_url)

    websocket.on :message do |event|
      data = JSON.parse(event.data)
      # puts "ON_MSG (thread #{thread_id}): #{data["method"]}/#{data["id"]}" if @debug
      # puts "ON_MSG (thread #{thread_id}): #{data}}" if @debug && data["method"] == nil && data["id"] && data["id"] < 10_000
      puts "ON_MSG (thread #{thread_id}): #{data}}" if @debug && (data['id'].nil? || data['id'] < 10_000)
      # puts "ON_MSG: #{data}" if data["method"] == nil && @debug
      # Network.loadingFinished
      # Page.frameStoppedLoading
      # Page.loadEventFired
      if data['method'] == 'Page.frameStoppedLoading'
        websocket.send(JSON.generate({
                                       id: 10_000 + next_id,
                                       method: 'Page.printToPDF',
                                       params: { printBackground: true,
                                                 marginTop: 3,
                                                 displayHeaderFooter: true,
                                                 headerTemplate: Thread.current[:work_item].header_html,
                                                 footerTemplate: Thread.current[:work_item].footer_html }
                                     }))
      end

      if data['id'] && data['id'] >= 10_000 && data['result']
        puts "PDF data received for thread #{thread_id}" if @debug
        pdf_data = Base64.decode64(data['result']['data'])

        # Notify the caller
        Thread.current[:work_item].callback&.call(pdf_data, Thread.current[:work_item])

        # Continue processing the next work item
        # unregister the message handler
        process_next_work_item(websocket, thread_id)
      end
    end

    websocket.on :open do |_event|
      puts "WebSocket opened to #{websocket_url} for thread #{thread_id}" if @debug
      # initialize the connection
      websocket.send(JSON.generate({ id: next_id, method: 'Network.enable' }))
      websocket.send(JSON.generate({ id: next_id, method: 'Page.enable' }))
      sleep 1
      puts "Network and Page enabled for thread #{thread_id}" if @debug
      yield(websocket) if block_given?
      # puts "WebSocket initialized for thread #{thread_id}" if @debug
    end

    websocket
  end

  def process_next_work_item(websocket, thread_id)
    work_item = @queue.pop
    Thread.current[:work_item] = work_item
    puts "Processing work item #{work_item[:data]} on thread #{thread_id}" if @debug

    # Start processing the work item
    content = work_item.body_html.gsub('{{thread_id}}', thread_id.to_s)
    encoded_content = Base64.strict_encode64(content)
    data_url = "data:text/html;base64,#{encoded_content}"

    websocket.send(JSON.generate({ id: next_id,
                                   method: 'Page.navigate',
                                   params: { url: data_url } }))
    puts "HTML #{content} #{work_item[:data]} loaded (page navigate) for thread #{thread_id}" if @debug
  end
end

# read count from CLI params
count = (ARGV[0] || 10).to_i

# read worker pool size from CLI params
worker_pool_size = (ARGV[1] || 2).to_i

# read debug from CLI params
debug = ARGV[2] == 'debug'

# Create work items to process
work_items = (1..count).map do |counter|
  current_counter = counter
  # Example HTML content for the body, header, and footer
  body_html = "<html><body><h1>PDF Content for {{thread_id}} - #{current_counter}</h1></body></html>"
  header_html = "<h1 style='width: 100%; text-align: center; font-size: 12pt;'>Header</h1>"
  footer_html = "<h1 style='width: 100%; text-align: center; font-size: 12pt;'>Footer</h1>"
  WorkItem.new(
    body_html, # body_html
    header_html, # header_html
    footer_html, # footer_html
    { counter: current_counter }, # data
    lambda do |binary_data, work_item|
      path = "tmp/test_page_#{work_item[:data][:counter]}.pdf"
      puts "PDF #{current_counter} saved to #{path}"
      File.binwrite(path, binary_data)
    end
  )
end

require 'benchmark'

latch = Concurrent::CountDownLatch.new(work_items.size)
benchmark = Benchmark.measure do
  # Initialize a latch that will wait for all work items to complete

  # Modify the work items to decrement the latch after completion
  work_items.each do |item|
    original_callback = item.callback
    item.callback = lambda { |binary_data, data|
      original_callback.call(binary_data, data)
      latch.count_down # Decrement the latch counter
    }
  end

  # Initialize WorkerPool with the desired number of threads
  puts "Initializing WorkerPool with #{worker_pool_size} threads" if debug
  worker_pool = WorkerPool.new(debug:)
  puts "Worker pool initialized with #{worker_pool_size} threads" if debug

  Thread.new { worker_pool.start(worker_pool_size) }

  # Add work items to the pool
  puts 'Adding work items to the pool' if debug
  work_items.each do |item|
    worker_pool.add_work(item)
  end

  # Wait for all work items to be processed before exiting
  latch.wait
  worker_pool.stop
end

puts 'All work items processed'
puts "Count: #{count}, Worker pool size: #{worker_pool_size}"
puts "Time elapsed: #{benchmark.real} seconds"
# sleep 0.1
