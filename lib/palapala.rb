# frozen_string_literal: true

require_relative 'palapala/version'
require_relative 'palapala/pdf'
require_relative 'palapala/web_socket_client'
require_relative 'palapala/renderer'

# Main module for the gem
module Palapala
  def self.setup
    yield self
  end

  class << self
    attr_accessor :defaults, :debug, :headless_chrome_url, :headless_chrome_path
  end

  self.headless_chrome_url = 'http://localhost:9222'
  self.headless_chrome_path = nil
  self.defaults = {}
  self.debug = false
end
