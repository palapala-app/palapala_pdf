# frozen_string_literal: true

require_relative 'test_helper'
require 'net/http'
require 'uri'

class TestBrowser < Minitest::Test
  # # This method will be called before any tests are run
  # def self.startup
  #   @@server ||= Palapala::Server.instance.start(wait: true)
  # end

  # # This method will be called after all tests are done
  # def self.shutdown
  #   @@server&.stop
  # end

  # # Ensure the server is available before running any tests
  # def setup
  #   self.class.startup
  # end

  # # Access the server instance
  # def server
  #   @@server
  # end

  def test_serve_and_remove_file
    server = Palapala::Server.new(port: 9224).start(wait: true)
    # Get the server instance
    hello_world = server.add_file('<h1>Hello, world!</h1>')
    url = server.url_for(hello_world)

    # fetch url with basic http client
    response = Net::HTTP.get_response(url)

    assert_equal '200', response.code
    assert_equal '<h1>Hello, world!</h1>', response.body

    server.remove_file(hello_world)
    # fetch url with basic http client
    response = Net::HTTP.get_response(url)
    assert_equal '404', response.code

    server.stop(wait: true)
  end

  def test_random_key_should_return_404
    server = Palapala::Server.new(port: 9225).start(wait: true)
    url = URI.parse("http://localhost:#{server.port}/file/#{SecureRandom.hex}")
    response = Net::HTTP.get_response(url)
    assert_equal '404', response.code
    server.stop(wait: true)
  end
end

# Register hooks for before and after the entire test suite
# Minitest.after_run { TestBrowser.shutdown }
