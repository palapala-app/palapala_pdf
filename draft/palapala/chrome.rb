# frozen_string_literal: true

require 'websocket/driver'
require 'json'
require 'base64'
require 'socket'
require 'net/http'
require 'faye/websocket'
require 'eventmachine'
# require "urle"
require 'uri'

module Palapala
  module Chrome
    CHROME_URL = 'http://localhost:9222'

    def self.next_id
      Thread.current[:id] ||= 1
      Thread.current[:id] += 1
    end

    def self.navigate_to_content(websocket, content, debug: false)
      encoded_content = Base64.strict_encode64(content)
      data_url = "data:text/html;base64,#{encoded_content}"

      websocket.send(JSON.generate({
                                     id: next_id,
                                     method: 'Page.navigate',
                                     params: { url: data_url }
                                   }))
      puts 'HTML content loaded' if debug
    end

    def self.pdf(body, path: nil, reps: 1, workers: 1, debug: false, **_opts)
      EM.run do
        threads_count = 0
        puts 'Started EventMachine' if debug
        puts "Workers: #{workers} starting" if debug
        (1..workers).map do |i|
          Thread.new do
            threads_count += 1
            # Create a new tab
            uri = URI("#{CHROME_URL}/json/new")
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Put.new(uri)
            response = http.request(request)
            tab_info = JSON.parse(response.body)
            websocket_url = tab_info['webSocketDebuggerUrl']
            puts "WebSocket URL: #{websocket_url.class} #{websocket_url}" if debug

            thread_id = "t#{i}"
            puts "Starting WebSocket connection t#{thread_id}" if debug
            # sleep 1
            websocket = Faye::WebSocket::Client.new(websocket_url)
            # store the websocket on thread local storage
            counter = 1
            websocket.on :open do |_event|
              # # Enable the Runtime domain to receive context events
              # websocket.send(JSON.generate({ id: 1, method: "Runtime.enable" }))
              websocket.send(JSON.generate({ id: next_id, method: 'Network.enable' }))
              websocket.send(JSON.generate({ id: next_id, method: 'Page.enable' }))
              content = body
                        .gsub('{{counter}}', counter.to_s)
                        .gsub('{{thread_id}}', thread_id)
              navigate_to_content(websocket, content, debug:)
            end

            websocket.on :message do |event|
              data = JSON.parse(event.data)

              # ready_event = "Network.loadingFinished"
              # ready_event = 'Page.loadEventFired'
              # ready_event = 'Page.domContentEventFired'
              ready_event = 'Page.frameStoppedLoading'
              if data['method'] == ready_event
                # Generate the PDF after the content is loaded
                puts "requesting PDF #{counter}/#{thread_id}" if debug
                websocket.send(JSON.generate({
                                               id: 10_000 + next_id,
                                               method: 'Page.printToPDF',
                                               params: { printBackground: true,
                                                         marginTop: 3,
                                                         displayHeaderFooter: true,
                                                         headerTemplate: HEADER_HTML,
                                                         footerTemplate: '<h1 style="width: 100%; text-align: center; font-size: 12pt;">Footer</h1>' }
                                             }))
              end

              # Capture PDF data when it's available
              if data['id'] && data['id'] >= 10_000 && data['result']
                if data['result']['data'].nil?
                  puts "OUCH no result data  #{counter}"
                  puts "data: #{data}" if debug
                  next
                end
                # puts data # Print the PDF data
                pdf_data = Base64.decode64(data['result']['data'])
                puts "PDF data received #{counter}/#{thread_id}" if debug

                # Save the PDF to a file
                unless path.nil?
                  File.binwrite(path.gsub('{{counter}}', counter.to_s).gsub('{{thread_id}}', thread_id), pdf_data)
                end

                # Loop or Close the WebSocket connection
                if counter < reps
                  # sleep 0.01
                  counter += 1
                  content = body
                            .gsub('{{counter}}', counter.to_s)
                            .gsub('{{thread_id}}', thread_id)
                  navigate_to_content(websocket, content)
                else
                  # sleep 0.1
                  websocket.close
                end
              end
            end

            websocket.on :close do |event|
              if debug
                puts "WebSocket closed with code: #{event.code}, reason: #{event.reason}, threads: #{threads_count}"
              end
              sleep 0.1
              threads_count -= 1
              EM.stop if threads_count.zero?
            end
          end
        end
      end
    end
  end
end
