# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'benchmark'
require 'palapala'

$debug = ARGV[0] == 'debug'
$save = ARGV[0] == 'save'

Palapala.debug = $debug

# @param concurrency Number of concurrent threads
# @param iterations Number of iterations per thread
def benchmark(concurrency, iterations)
  time = Benchmark.realtime do
    threads = (1..concurrency).map do |i|
      Thread.new do
        iterations.times do |j|
          doc = "Hello #{i}, <b>world</b> #{j}! <i>#{Time.now}</i>.<br/><img src='https://www.ruby-lang.org/images/header-ruby-logo.png' />"
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
puts "Starting benchmark step 2..."
benchmark(2, 20)
benchmark(2, 40)
benchmark(2, 80)
benchmark(4, 160)
# benchmark(4, 320 / 4)
