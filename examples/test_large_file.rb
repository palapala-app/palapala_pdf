#!/usr/bin/env ruby
# Test script to debug large file processing

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'benchmark'
require 'palapala'

# Enable debug logging
Palapala.debug = true

puts "Testing large file processing..."

# Generate a large HTML file (> 2MB)
doc = "Hello, world! <i>#{Time.now}</i>. 00001: 0123456789 The quick brown fox jumps over the lazy dog.\n"
# make doc double the size untiul it's bigger than html_size
doc *= (2_000_000 / doc.bytesize) + 1
# doc *= (10_000 / doc.bytesize) + 1
large_html = "<html><body><pre>#{doc}</pre></body></html>"

# save the generated file as large_file.html
# File.write("large_file.html", large_html)

puts "Generated HTML: #{large_html.bytesize} bytes"

begin
  puts "Starting PDF generation..."
  pdf_data = Palapala::Renderer.html_to_pdf(large_html)
  puts "Success! Generated PDF: #{pdf_data.length} bytes"
rescue => e
  puts "Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(5).join("\n")}"
end
