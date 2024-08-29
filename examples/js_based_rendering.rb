# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

DOCUMENT = <<~HTML
  <html>
    <script type="text/javascript">
      document.addEventListener("DOMContentLoaded", () => {
        document.body.innerHTML += "<p>Current time from JS: " + new Date().toLocaleString() + "</p>";
      });
    </script>
    <body><p>Default body text.</p></body>
  </html>
HTML

Palapala.setup do |config|
  # config.debug = true
  # config.defaults = { header_template: '<div></div>', footer_template: '<div></div>' }
end

Palapala::Pdf.new(DOCUMENT).save('tmp/js_based_rendering.pdf')
`open tmp/js_based_rendering.pdf`
