require_relative "palapala/pdf"
require_relative "palapala/version"

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

    # Chrome headless shell version to use
    attr_accessor :chrome_headless_shell_version
  end
  puts "setting defaults on palapala"
  self.debug = false
  self.defaults = { displayHeaderFooter: true, encoding: :binary }
  self.headless_chrome_path = nil
  self.headless_chrome_url = "http://localhost:9222"
  self.chrome_headless_shell_version = ENV.fetch("CHROME_HEADLESS_SHELL_VERSION", "stable")
end

puts "hoo"
