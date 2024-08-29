# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

HEADER_HTML = <<~HTML
  <style type="text/css">
    .header {
      -webkit-print-color-adjust: exact;
      border-bottom: 1px solid lightgray;
      color: black;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 12pt;
      margin: 0 auto;
      padding: 5px;
      text-align: center;
      vertical-align: middle;
      width: 100%;
      border: 1px solid black;
    }
  </style>
  <div class="header" style="text-align: center">
    Page <span class="pageNumber"></span> of <span class="totalPages"></span>
  </div>
HTML

Palapala.setup do |config|
  # config.debug = true
  # config.headless_chrome_url = 'http://localhost:9222' # run against a remote Chrome instance
  # config.headless_chrome_path = '/usr/bin/google-chrome-stable' # path to Chrome executable
end

result = Palapala::Pdf.new(
  # "<style>@page { size: A4 landscape; }</style><p>Hello world #{Time.now}</>",
  "<h1>Title</h1><p>Hello world #{Time.now}</>",
  header_template: HEADER_HTML,
  footer_template: '<div style="text-align: center; font-size: 12pt; width: 100%;">Generated with Palapala PDF</div>',
  scale: 0.75,
  prefer_css_page_size: false,
  margin_top: 3,
  margin_bottom: 2).save('tmp/headers_and_footers.pdf')

puts result
`open tmp/headers_and_footers.pdf`
