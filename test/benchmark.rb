# frozen_string_literal: true

require 'benchmark'
require_relative '../lib/palapala'

HELLO_WORLD = <<~HTML.freeze
  Hello, world! #{Time.now}.
HTML
DOCUMENT = HELLO_WORLD * 1

Palapala.setup do |config|
  # config.ferrum_opts = { url: 'http://localhost:9222' }
  config.defaults.merge! scale: 0.75, format: :A4
end

Palapala::Pdf.new(DOCUMENT).save('tmp/benchmark.pdf')

# @param concurrency Number of concurrent threads
# @param iterations Number of iterations per thread
def benchmark(concurrency, iterations)
  time = Benchmark.realtime do
    threads = (1..concurrency).map do |_i|
      Thread.new do
        iterations.times do
          Palapala::Pdf.new(DOCUMENT).binary_data
        end
      end
    end
    threads.each(&:join)
  end
  puts "Total time c:#{concurrency}, n:#{iterations} = #{time} seconds"
  time
end


puts 'warmup'
benchmark(1, 10)

puts 'benchmarking 20 docs: 1x20, 2x10, 4x5, 5x4, 20x1'
benchmark(1, 20)
benchmark(2, 10)
benchmark(4, 5)
benchmark(5, 4)
benchmark(20, 1)

puts 'benchmarking 40 docs'
benchmark(1, 40)
benchmark(4, 10)
benchmark(8, 5)
benchmark(20, 2)
benchmark(40, 1)
