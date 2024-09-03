# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

header =
  '<div class="center">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>'

left_center_right = <<~HTML
<div style="display: flex; justify-content: space-between; width: 100%; margin-left: 1cm; margin-right: 1cm;">
    <div style="text-align: left; flex: 1;">Left Text</div>
    <div style="text-align: center; flex: 1;">Center Text</div>
    <div style="text-align: right; flex: 1;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>
</div>
HTML

footer =
  '<span>Generated at&nbsp;<span class="date"></span></span>'

Palapala::Pdf.new(
  "<h1>Title</h1><p>Hello world #{Time.now}</>",
  header: left_center_right,
  footer:,
  margin_top: 1,
  margin_left: 1,
  margin_bottom: 1,
  watermark: "CLASSIFIED").save('headers_and_footers.pdf')

puts "Generated headers_and_footers.pdf"
# `open headers_and_footers.pdf`
