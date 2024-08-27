# frozen_string_literal: true

# require 'minitest/autorun'
require_relative '../lib/palapala/chrome'

# class PalapalaChromeTest < Minitest::Test

#   def test_create_pdf_from_html
#     Palapala::Chrome.pdf("<h1>Hello, world! #{Time.now}</h1>", path: 'tmp/test_page.pdf')
#   end
# end

# Palapala::Chrome.pdf("<h1>Hello, world! #{Time.now}</h1>",
#                      path: 'tmp/test_page_{{counter}}.pdf')

HELLO_PDF = <<~HTML
  <html><body><h1>Hello, PDF!</h1></body></html>
HTML

JS_DOCUMENT = <<~HTML
  <html>
    <script type="text/javascript">
      document.addEventListener("DOMContentLoaded", () => {
        document.body.innerHTML += "<p>Current time from JS: " + new Date().toLocaleString() + "</p>";
      });
    </script>
    <body><p>Default body text.</p></body>
  </html>
HTML

HEADER_HTML = <<~HTML
  <style>
    .header {
      font-size: 18px;
      font-family: Arial, sans-serif;
      color: black;
      padding: 10px;
    }
  </style>
  <h1 class="header">Header</h1>
HTML

def run(workers: 8, reps: 100, path: nil)
  require 'benchmark'
  benchmark = Benchmark.measure do
    Palapala::Chrome.pdf("<h1>Hello {{counter}}, world {{thread_id}}! #{Time.now}</h1>",
                         workers:,
                         path:,
                         reps:)
  end
  puts "Time elapsed: #{benchmark.real} seconds for #{workers} workers and #{reps} repetitions"
end
run(workers: 1, reps: 10)
run(workers: 2, reps: 50, path: 'tmp/2_50_test_page_{{thread_id}}_{{counter}}.pdf')
run(workers: 4, reps: 25, path: 'tmp/4_25_test_page_{{thread_id}}_{{counter}}.pdf')

# run(workers: 8, reps: 10)
# run(workers: 4, reps: 20)
# run(workers: 2, reps: 40)
# run(workers: 1, reps: 80)
# run(workers: 8, reps: 100)
# run(workers: 4, reps: 200)
# run(workers: 2, reps: 400)
# run(workers: 1, reps: 800)
