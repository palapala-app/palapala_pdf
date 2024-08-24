# PDF Generation for your Rubies

This project is a Ruby gem that provides functionality for generating PDF files from HTML using the Chrome browser. It allows you to easily convert HTML content into PDF documents, making it convenient for tasks such as generating reports, invoices, or any other printable documents. The gem provides a simple and intuitive API for converting HTML to PDF, and it leverages the power and flexibility of the Chrome browser's rendering engine to ensure accurate and high-quality PDF output. With this gem, you can easily integrate PDF generation capabilities into your Ruby applications.

At the core, this project leverages the same rendering engine as [Grover](https://github.com/Studiosity/grover), but with significantly reduced overhead and dependencies. Instead of relying on the full Grover/Puppeteer/NodeJS stack, this project builds on [Ferrum](https://github.com/rubycdp/ferrum) to enable direct communication from Ruby to a headless Chrome or Chromium browser. This approach ensures efficient, thread-safe operations, providing a streamlined alternative for rendering tasks without sacrificing performance or flexibility.

This is how easy and powerfull PDF generation should be in Ruby:

```ruby
require "palapala"
Palapala::PDF.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```

And this while having the most modern HTML/CSS/JS availlable to you: flex, grid, canvas, you name it.

## Installation

To install the gem and add it to your application's Gemfile, execute the following command:

```
$ bundle add palapala_pdf
```

If you are not using bundler to manage dependencies, you can install the gem by running:

```
$ gem install palapala_pdf
```

Palapala PDF uses [Ferrum](https://github.com/rubycdp/ferrum) inside and that one is pretty good at finding your Chrome or Chromium.

If you want the highest throughput, then use an external Chrome/Chromium. Just start it with (9222 is the default port):

```sh
chrome --headless --disable-gpu --remote-debugging-port=9222
```

Then you can run Palapala PDF against that Chrome/Chromium instance (see configuration).

## Usage Instructions

To create a PDF from HTML content using the `Palapala` library, follow these steps:

1. **Configuration**:

Configure the `Palapala` library with the necessary options, such as the URL for the Ferrum browser and default settings like scale and format.

In a Rails context, this could be inside an initializer.

```ruby
Palapala.setup do |config|
    # run against an external chrome/chromium or leave this out to run against a chrome that is started as a child process
    config.ferrum_opts = { url: 'http://localhost:9222' }
    config.defaults = { scale: 1, format: :A4 }
end
```

2. **Create a PDF from HTML**:

Create a PDF file from HTML in IRB

```sh
gem install palapala_pdf
```

in IRB, load palapala and create a PDF from an HTML snippet:

```sh
>irb
```

```ruby
require "palapala"
Palapala::PDF.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```

Instantiate a new Palapala::PDF object with your HTML content and generate the PDF binary data.

```ruby
require "palapala"
binary_data = Palapala::PDF.new("<h1>Hello, world! #{Time.now}</h1>").binary_data
```

# Paged CSS

Paged CSS is a subset of CSS designed for styling printed documents. It extends standard CSS to handle pagination, page sizes, headers, footers, and other aspects of printed content. Paged CSS is commonly used in scenarios where web content needs to be converted to PDFs or other paginated formats.

### Headers and Footers

When using Chromium-based rendering engines, headers and footers are not controlled by the Paged CSS standard but are instead managed through specific settings in the rendering engine.

With palapala PDF headers and footers are defined using `header_html` and `footer_html` options. These allow you to insert HTML content directly into the header or footer areas.

```ruby
Palapala::PDF.new(
  "<p>Hello world</>",
  header_html: '<div style="text-align: center;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>',
  footer_html: '<div style="text-align: center;">Generated with Palapala PDF</div>',
  margin: { top: "2cm", bottom: "2cm"}
).save("test.pdf")
)

### Page sizes in CSS

explain about @paged css elements that set page sizes and margins etc

Unlike Paged CSS, where margins are defined within `@page`, in Chromium, you control the header and footer margins separately using `margin-top` and `margin-bottom`. For example:

## Customisation

### Ferrum

It is Ruby clean and high-level API to Chrome. All you need is Ruby and
[Chrome](https://www.google.com/chrome/) or
[Chromium](https://www.chromium.org/). Ferrum connects to the browser by [CDP
protocol](https://chromedevtools.github.io/devtools-protocol/).

Highlighting some key Ferrum options in the context of PDF generation

* options `Hash`
  * `:headless` (String | Boolean) - Set browser as headless or not, `true` by default. You can set `"new"` to support
      [new headless mode](https://developer.chrome.com/articles/new-headless/).
  * `:xvfb` (Boolean) - Run browser in a virtual framebuffer, `false` by default.
  * `:extensions` (Array[String | Hash]) - An array of paths to files or JS
      source code to be preloaded into the browser e.g.:
      `["/path/to/script.js", { source: "window.secret = 'top'" }]`
  * `:logger` (Object responding to `puts`) - When present, debug output is
      written to this object.
  * `:timeout` (Numeric) - The number of seconds we'll wait for a response when
      communicating with browser. Default is 5.
  * `:js_errors` (Boolean) - When true, JavaScript errors get re-raised in Ruby.
  * `:pending_connection_errors` (Boolean) - When main frame is still waiting for slow responses while timeout is
      reached `PendingConnectionsError` is raised. It's better to figure out why you have slow responses and fix or
      block them rather than turn this setting off. Default is true.
  * `:browser_path` (String) - Path to Chrome binary, you can also set ENV
      variable as `BROWSER_PATH=some/path/chrome`.
  * `:browser_options` (Hash) - Additional command line options,
      [see them all](https://peter.sh/experiments/chromium-command-line-switches/)
      e.g. `{ "ignore-certificate-errors" => nil }`
  * `:ignore_default_browser_options` (Boolean) - Ferrum has a number of default
      options it passes to the browser, if you set this to `true` then only
      options you put in `:browser_options` will be passed to the browser,
      except required ones of course.
  * `:url` (String) - URL for a running instance of Chrome. If this is set, a
      browser process will not be spawned.
  * `:process_timeout` (Integer) - How long to wait for the Chrome process to
      respond on startup.
  * `:ws_max_receive_size` (Integer) - How big messages to accept from Chrome
      over the web socket, in bytes. Defaults to 64MB. Incoming messages larger
      than this will cause a `Ferrum::DeadBrowserError`.

More [details](https://github.com/rubycdp/ferrum#customization)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palapala-app/palapala_pdf.

## Contributors

- [Kenneth Geerts](https://github.com/kennethgeerts) - Your foundational contributions to simplicity are greatly appreciated.
- [Eugen Neagoe](https://github.com/eneagoe) - Thank you for your valuable input, feedback and opinions.

## Sponsor This Project

If you find this project useful and would like to support its development, consider sponsoring or buying a coffee to help keep it going:

- **GitHub Sponsors:** [Sponsor on GitHub](https://github.com/sponsors/koenhandekyn)
- **Buy Me a Coffee:** [Buy a Coffee](https://buymeacoffee.com/koenhandekyn)

Your support is greatly appreciated and helps maintain the project!

## Findings

For Chrome, mode headless=new seems to be slower for pdf rendering cases.

## Primitive benchmark

On a macbook m3, the throughput for 'hello world' PDF generation can reach around 25 docs/second when allowing for some concurrency. As Chrome is actually also very efficient, it scales really well for complex documents also. If you run this in Rails, the concurrency is being taken care of either by the front end thread pool or by the workers and you shouldn't have to think about this. (Using an external Chrome)


```
benchmarking 20 docs: 1x20, 2x10, 4x5, 5x4, 20x1 (c is concurrency, n is iterations)
Total time c:1, n:20 = 1.2048690000083297 seconds
Total time c:2, n:10 = 0.8969700000016019 seconds
Total time c:4, n:5 = 0.7497870000079274 seconds
Total time c:5, n:4 = 0.72492800001055 seconds
Total time c:20, n:1 = 0.7156629998935387 seconds
```

## Docker

In docker as root you must pass the no-sandbox browser option:

```ruby
Ferrum::Browser.new(browser_options: { 'no-sandbox': nil })
```

It has also been reported that the Chrome process repeatedly crashes when running inside a Docker container on an M1 Mac preventing Ferrum from working. Ferrum should work as expected when deployed to a Docker container on a non-M1 Mac.
