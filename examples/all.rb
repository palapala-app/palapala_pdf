$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

$debug = ARGV[0] == 'debug'
Palapala.debug = $debug

require_relative "headers_and_footers"
require_relative "paged_css"
require_relative "js_based_rendering"
