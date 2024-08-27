# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'palapala'

iterations = (ARGV[0] || 10).to_i
thread_count = (ARGV[1] || 1).to_i
debug = ARGV[2] == 'debug'

Palapala.debug = debug

require 'benchmark'
benchmark = Benchmark.measure do
  threads = (1..thread_count).map do |t|
    Thread.new do
      renderer = Palapala::Renderer.new
      (1..iterations).map do |i|
        hello_pdf = "<html><body><h1>Hello #{t}/#{i}, PDF!</h1></body></html>"
        js_pdf = <<~HTML
          <html>
            <script type="text/javascript">
              document.addEventListener("DOMContentLoaded", () => {
                document.body.innerHTML += "<p>Current time from JS: " + new Date().toLocaleString() + "</p>";
                for (let i = 0; i < 10; i++) {
                  document.body.innerHTML += "<p>Random: " + Math.random() + "</p>";
                }
              });
            </script>
            <body><p>Default body text #{t}/#{i}</p></body>
          </html>
        HTML
        pdf_data = renderer.html_to_pdf(eval(ARGV[4] || 'hello_pdf'))
        # puts "PDF data received #{pdf_data.length} bytes"
        print "."
        File.binwrite("tmp/hello_#{t}_#{i}.pdf", pdf_data) if ARGV[3] == 'save'
      end
      renderer.close
    end
  end
  threads.each(&:join)
end

puts "Benchmark: #{benchmark}"
puts "Time elapsed: #{benchmark.real} seconds"
