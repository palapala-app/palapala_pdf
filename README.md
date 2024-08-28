# PDF Generation for your Rubies

<div style="float: right; padding: 3em"><img src="https://raw.githubusercontent.com/palapala-app/palapala_pdf/main/assets/images/logo.webp" alt="Palapala PDF Logo" width="200"></div>

This project is a Ruby gem that provides functionality for generating PDF files from HTML using the Chrome browser. It allows you to easily convert HTML content into PDF documents, making it convenient for tasks such as generating reports, invoices, or any other printable documents. The gem provides a simple and intuitive API for converting HTML to PDF, and it leverages the power and flexibility of the Chrome browser's rendering engine to ensure accurate and high-quality PDF output. With this gem, you can easily integrate PDF generation capabilities into your Ruby applications.

At the core, this project leverages the same rendering engine as [Grover](https://github.com/Studiosity/grover), but with significantly reduced overhead and dependencies. Instead of relying on the full Grover/Puppeteer/NodeJS stack, this project uses a raw web socket to enable direct communication from Ruby to a headless Chrome or Chromium browser. This approach ensures efficieny while providing a streamlined alternative for rendering tasks without sacrificing performance or flexibility.

This is how easy PDF generation can be in Ruby:

```ruby
require "palapala"
Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```
And this while having the most modern HTML/CSS/JS availlable to you: flex, grid, canvas, ...

A core goal of this project is performance, and it is designed to be exceptionally fast. By leveraging **direct communication** with a headless Chrome or Chromium browser via a **raw web socket**, the gem minimizes overhead and dependencies, enabling PDF generation at speeds that significantly outperform other solutions. Whether generating simple or complex documents, this gem ensures that your Ruby applications can handle PDF tasks efficiently and at scale.

## Installation

To install the gem and add it to your application's Gemfile, execute the following command:

```
$ bundle add palapala_pdf
```

If you are not using bundler to manage dependencies, you can install the gem by running:

```
$ gem install palapala_pdf
```

Palapala PDF connects to Chrome over a web socket connection.

An external Chrome/Chromium is expected.
Just start it with the following command (9222 is the default port):

```sh
/path/to/chrome --headless --disable-gpu --remote-debugging-port=9222
```

Alternatively, Palapala PDF will try to launch Chrome as a child process.
It guesses the path to Chrome, or you configure it like this:

```ruby
Palapala.setup do |config|
    config.headless_chrome_path = '/usr/bin/google-chrome-stable' # path to Chrome executable
end
```

## Usage Instructions

To create a PDF from HTML content using the `Palapala` library, follow these steps:

1. **Configuration**:

Configure the `Palapala` library with the necessary options, such as the URL for the browser and default settings like scale and format.

In a Rails context, this could be inside an initializer.

```ruby
Palapala.setup do |config|
    # run against an external chrome/chromium or leave this out to run against a chrome that is started as a child process
    config.debug = true
    config.headless_chrome_url = 'http://localhost:9222' # run against a remote Chrome instance
    # config.headless_chrome_path = '/usr/bin/google-chrome-stable' # path to Chrome executable
    config.defaults = { scale: 1, format: :A4 }
end
```
1. **Create a PDF from HTML**:

Create a PDF file from HTML in `irb`

```sh
gem install palapala_pdf
```

in IRB, load palapala and create a PDF from an HTML snippet:

```ruby
require "palapala"
Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```

Instantiate a new Palapala::Pdf object with your HTML content and generate the PDF binary data.

```ruby
require "palapala"
binary_data = Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").binary_data
```

## Paged CSS

Paged CSS is a subset of CSS designed for styling printed documents. It extends standard CSS to handle pagination, page sizes, headers, footers, and other aspects of printed content. Paged CSS is commonly used in scenarios where web content needs to be converted to PDFs or other paginated formats.

### Headers and Footers

When using Chromium-based rendering engines, headers and footers are not controlled by the Paged CSS standard but are instead managed through specific settings in the rendering engine.

With palapala PDF headers and footers are defined using `header_html` and `footer_html` options. These allow you to insert HTML content directly into the header or footer areas.

```ruby
Palapala::Pdf.new(
  "<p>Hello world</>",
  header_html: '<div style="text-align: center;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>',
  footer_html: '<div style="text-align: center;">Generated with Palapala PDF</div>',
  margin: { top: "2cm", bottom: "2cm"}
).save("test.pdf")
```

### Page size, orientation and margins

#### With CSS

todo example

#### As params

todo example

## JS based rendering

```html
  <html>
    <script type="text/javascript">
      document.addEventListener("DOMContentLoaded", () => {
        document.body.innerHTML += "<p>Current time from JS: " + new Date().toLocaleString() + "</p>";
      });
    </script>
    <body><p>Default body text.</p></body>
  </html>
```

## Raw parameters (Page.printToPDF)

See (Page.printToPDF)[https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF]

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

- For Chrome, mode headless=new seems to be slower for pdf rendering cases.
- On mac m3 (aug 24), chromium (brew install chromium) is about 3x slower then chrome? Maybe the chromium that get's installed is not ARM optimized?

## Primitive benchmark

On a macbook m3, the throughput for 'hello world' PDF generation can reach around 300 docs/second when allowing for some concurrency. As Chrome is actually also very efficient, it scales really well for complex documents also. If you run this in Rails, the concurrency is being taken care of either by the front end thread pool or by the workers and you shouldn't have to think about this. (Using an external Chrome)

Note: it renders `"Hello #{i}, world #{j}! #{Time.now}."` where i is the thread and j is the iteration counter within the thread and persists it to an SSD (which is very fast these days).

### benchmarking 20 docs: 1x20, 2x10, 4x5

```sh
c:1, n:20 : Throughput = 159.41 docs/sec, Total time = 0.1255 seconds
c:2, n:10 : Throughput = 124.91 docs/sec, Total time = 0.1601 seconds
c:4, n:5  : Throughput = 196.40 docs/sec, Total time = 0.1018 seconds
```

### benchmarking 320 docs: 1x320, 4x80, 8x40

```sh
c:1, n:320 : Throughput = 184.99 docs/sec, Total time = 1.7299 seconds
c:4, n:80  : Throughput = 302.50 docs/sec, Total time = 1.0578 seconds
c:8, n:40  : Throughput = 254.29 docs/sec, Total time = 1.2584 seconds
```

This is about a factor 100x faster then what you typically get with Grover and still 10x faster then with many alternatives. It's effectively that fast that you can run this for a lot of uses cases straight from e.g. your Ruby On Rails web worker in the controller on a single machine and still scale to lot's of users.

## Rails

### `send_data` and `render_to_string`

The `send_data` method in Rails is used to send binary data as a file download to the user's browser. It allows you to send any type of data, such as PDF files, images, or CSV files, directly to the user without saving the file on the server.

The `render_to_string` method in Rails is used to render a view template to a string without sending it as a response to the user's browser. It allows you to generate HTML or other text-based content that can be used in various ways, such as sending it as an email, saving it to a file, or manipulating it further before sending it as a response.

Here's an example of how to use `render_to_string` to render a view template to a string and send the pdf using `send_data`:

```ruby
def download_pdf
    html_string = render_to_string(template: "example/template", layout: "print", locals: { } )
    pdf_data = Palapala::Pdf.new(html_string).binary_data
    send_data pdf_data, filename: "document.pdf", type: "application/pdf"
end
```

In this example, `pdf_data` is the binary data of the PDF file. The `filename` option specifies the name of the file that will be downloaded by the user, and the `type` option specifies the MIME type of the file.

## Docker

In docker as root you must pass the no-sandbox browser option:

```ruby
Palapala.setup do |config|
  config.opts = { 'no-sandbox': nil }
end
```
It has also been reported that the Chrome process repeatedly crashes when running inside a Docker container on an M1 Mac. Chrome should work as expected when deployed to a Docker container on a non-M1 Mac.

## Thread-safety

Behind the scenes, a websocket is openend and stored on Thread.current for subsequent requests. Hence, the code is
thread safe in the sense that every web socket get's a new tab in the underlying chromium and get an isolated context.

For performance reasons, the code uses a low level websocket connection that does all it's work on the curent thread
so we can avoid synchronisation penalties.

## Heroku

possible buildpacks

https://github.com/heroku/heroku-buildpack-chrome-for-testing

this buildpack install chrome and chromedriver, which is actually not needed, but it's maintained

https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-google-chrome

this buildpack installs chrome, which is all we need, but it's deprecated
