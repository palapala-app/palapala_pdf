# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'benchmark'
require 'palapala'

$debug = ARGV[0] == 'debug'
$save = ARGV[0] == 'save'

Palapala.debug = $debug

# @param concurrency Number of concurrent threads
# @param iterations Number of iterations per thread
def benchmark(concurrency, iterations, html_size: 1)
  time = Benchmark.realtime do
    threads = (1..concurrency).map do |i|
      Thread.new do
        iterations.times do |j|
          # doc = "Hello #{i}, <b>world</b> #{j}! <i>#{Time.now}</i>. 00001: 0123456789 The quick brown fox jumps over the lazy dog.\n"
          doc = "Hello #{i}, world #{j}! <i>#{Time.now}</i>. 00001: 0123456789 The quick brown fox jumps over the lazy dog.\n"
          # make doc double the size untiul it's bigger than html_size
          doc *= (html_size / doc.bytesize) + 1
          doc = "<html><body><pre>#{doc}</pre></body></html>"
          pdf = Palapala::Pdf.new(doc)
          $save ? pdf.save("tmp/benchmark_#{i}_#{j}.pdf") : pdf.binary_data
        end
      end
    end
    threads.each(&:join)
  end
  puts "c:#{concurrency}, n:#{iterations} : Throughput = #{(concurrency * iterations / time).round(2)} docs/sec, Total time = #{time.round(4)} seconds"
  time
end

puts "Warmup..."
benchmark(1, 5)
puts "Starting benchmark..."
benchmark(1, 10)
benchmark(2, 20 / 2)
puts "Starting benchmark step 2 (small docs)..."
benchmark(2, 20)
benchmark(2, 40)
benchmark(2, 80)
benchmark(4, 40)
benchmark(8, 20)
puts "Starting benchmark step 2 (medium docs)..."
benchmark(2, 20, html_size: 10_000)
benchmark(2, 40, html_size: 10_000)
benchmark(2, 80, html_size: 10_000)
benchmark(4, 40, html_size: 10_000)
benchmark(8, 20, html_size: 10_000)
puts "Starting benchmark with html size 2 000 000 ..."
# benchmark(1, 1, html_size: 1_500_000)
benchmark(1, 1, html_size: 2_000_000)
