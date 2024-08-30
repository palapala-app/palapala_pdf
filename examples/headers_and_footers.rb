# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

header_template =
  '<div style="text-align: center; font-size: 12pt; padding: 1rem; width: 100%;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>'

footer_template =
  '<div style="text-align: center; font-size: 12pt; padding: 1rem; width: 100%;">Generated with Palapala PDF</div>'

Palapala::Pdf.new(
  "<h1>Title</h1><p>Hello world #{Time.now}</>",
  header_template:,
  footer_template:,
  margin_top: 3,
  margin_bottom: 3).save('headers_and_footers.pdf')

puts "Generated headers_and_footers.pdf"
# `open headers_and_footers.pdf`
