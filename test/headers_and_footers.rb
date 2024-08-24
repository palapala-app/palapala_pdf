$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require_relative 'palapala'

Palapala::PDF.new(
  "<p>Hello world</>",
  header_html: '<div style="text-align: center;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>',
  footer_html: '<div style="text-align: center;">Generated with Palapala PDF</div>',
  margin: { top: "2cm", bottom: "2cm"}
).save("test.pdf")
