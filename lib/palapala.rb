require_relative "palapala/pdf"
require_relative "palapala/version"

# Main module for the gem
module Palapala
  def self.setup
    yield self
  end

  class << self
    # params to pass to Chrome when launched as a child process
    attr_accessor :chrome_params

    # debug mode
    attr_accessor :debug

    # default options for PDF generation
    attr_accessor :defaults

    # path to the headless Chrome executable when using the child process renderer
    attr_accessor :headless_chrome_path

    # URL to the headless Chrome instance when using the remote renderer
    attr_accessor :headless_chrome_url
  end

  self.debug = false
  self.defaults = { displayHeaderFooter: true, encoding: :binary }
  self.headless_chrome_path = nil
  self.headless_chrome_url = "http://localhost:9222"
end
