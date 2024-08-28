# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'benchmark'
require 'palapala'

debug = ARGV[0] == 'debug'

Palapala.setup do |config|
  # config.headless_chrome_url = 'http://localhost:9222'
  config.debug = debug
  config.defaults.merge! scale: 0.75, format: :A4
end

Palapala::Pdf.new(DOCUMENT).save('tmp/benchmark.pdf')

# @param concurrency Number of concurrent threads
# @param iterations Number of iterations per thread
def benchmark(concurrency, iterations)
  time = Benchmark.realtime do
    threads = (1..concurrency).map do |i|
      Thread.new do
        iterations.times do |j|
          doc = "Hello #{i}, world #{j}! #{Time.now}."
          Palapala::Pdf.new(doc).save("tmp/benchmark_#{i}_#{j}.pdf")
        end
      end
    end
    threads.each(&:join)
  end
  puts "c:#{concurrency}, n:#{iterations} : Throughput = #{(concurrency * iterations / time).round(2)} docs/sec, Total time = #{time.round(4)} seconds"
  time
end

puts 'warmup'
benchmark(1, 10)

puts 'benchmarking 20 docs: 1x20, 2x10, 4x5, 5x4, 20x1'
benchmark(1, 20)
benchmark(2, 10)
benchmark(4, 5)
# benchmark(5, 4)
# benchmark(20, 1)

puts 'benchmarking 320 docs'
benchmark(1, 320)
benchmark(2, 320 / 2)
benchmark(4, 320 / 4)
benchmark(8, 320 / 8)
# benchmark(20, 2)
# benchmark(40, 1)
