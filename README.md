# PDF Generation for your Rubies

<div align="center"><img src="https://raw.githubusercontent.com/palapala-app/palapala_pdf/main/assets/images/logo.webp" alt="Palapala PDF Logo" width="200"></div>

This project is a Ruby gem that provides functionality for generating PDF files from HTML using the Chrome browser. It allows you to easily convert HTML content into PDF documents, making it convenient for tasks such as generating reports, invoices, or any other printable documents. The gem provides a simple and intuitive API for converting HTML to PDF, and it leverages the power and flexibility of the Chrome browser's rendering engine to ensure accurate and high-quality PDF output. With this gem, you can easily integrate PDF generation capabilities into your Ruby applications.

At the core, this project leverages the Chrome rendering engine, but with significantly reduced overhead and dependencies. Instead of relying on the full Grover/Puppeteer/NodeJS stack, this project uses a raw web socket to enable direct communication from Ruby to a headless Chrome or Chromium browser. This approach ensures efficieny while providing a streamlined alternative for rendering tasks without sacrificing performance or flexibility.

It leverages work from [Puppeteer](https://pptr.dev/browsers-api/) (@puppeteer/browsers) to install a local Chrome-Headless-Shell if no Chrome is running, but that requires node (npx) to be available.

This is how easy PDF generation can be in Ruby:

```ruby
require "palapala"
Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```
And this while having the most modern HTML/CSS/JS availlable to you: flex, grid, canvas, ...

A core goal of this project is performance, and it is designed to be exceptionally fast. By leveraging **direct communication** with a headless Chrome or Chromium browser via a **raw web socket**, the gem minimizes overhead and dependencies, enabling PDF generation at speeds that significantly outperform other solutions. Whether generating simple or complex documents, this gem ensures that your Ruby applications can handle PDF tasks efficiently and at scale.

[Example: paged_css.pdf](https://raw.githubusercontent.com/palapala-app/palapala_pdf/main/examples/paged_css.pdf)

## Sponsor This Project

If you find this project useful and would like to support its development, consider sponsoring or buying a coffee to help keep it going:

- **GitHub Sponsors:** [Sponsor on GitHub](https://github.com/sponsors/koenhandekyn)
- **Buy Me a Coffee:** [Buy a Coffee](https://buymeacoffee.com/koenhandekyn)

Your support is greatly appreciated and helps maintain the project!

## Installation

To install the gem and add it to your application's Gemfile, execute the following command:

```
$ bundle add palapala_pdf
```

## Usage Instructions

To create a PDF from HTML content using the `Palapala` library, follow these steps:

**Configuration from inside Ruby**

Configure the `Palapala` library with the necessary options, such as the URL for the browser and default settings like scale and format.

In a Rails context, this could be inside an initializer.

```ruby
Palapala.setup do |config|
    # debug mode
    config.debug = true
    # Chrome headless shell version to use (stable, beta, dev, canary, etc.) when launching a new Chrome instance
    config.chrome_headless_shell_version = :stable
    # run against an external chrome/chromium or leave this out to run against a chrome that is started as a child process
    config.headless_chrome_url = 'http://localhost:9222'
    # path to Chrome executable
    config.headless_chrome_path = '/usr/bin/google-chrome-stable'
    # default options for PDF generation
    config.defaults = { scale: 1 }
    # extra params to pass to Chrome when launched as a child process
    config.chrome_params = []
end
```

**Using environemnt variables**

```sh
CHROME_HEADLESS_SHELL_VERSION=canary ruby examples/performance_benchmark.rb
````

```sh
HEADLESS_CHROME_URL=http://192.168.1.1:9222 ruby examples/performance_benchmark.rb
```

```sh
HEADLESS_CHROME_PATH=/var/to/chrome ruby examples/performance_benchmark.rb
```

**Create a PDF from HTML**

Load palapala and create a PDF file from an HTML snippet:

```ruby
require "palapala"
Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").save('hello.pdf')
```

Instantiate a new Palapala::Pdf object with your HTML content and generate the PDF binary data:

```ruby
require "palapala"
binary_data = Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>").binary_data
```

## Advanced Examples

- headers and footers
- watermark
- paged css for paper sizes, paper margins, pages breaks, etc
- js based rendering

## Connecting to Chrome

Palapa PDF will go through this process

- check if a Chrome is running and exposing port 9222 (and if so, use it)
- if `Palapala.headless_chrome_path` is defined, launch Chrome as a child process using that path
- if **NPX** is avalaillable, install a **Chrome-Headless-Shell** variant locally and launch it as a child process. It will install the 'stable' version or the version identified by `Palapala.chrome_headless_shell_version` setting (or from ENV `CHROME_HEADLESS_SHELL_VERSION`).
- as a last fallback it will guess a chrome path from the detected OS and try to launch a Chrome with that

In our expreience a Chrome-Headless-Shell version gives the best performance and resource useage.

### Installing Chrome / Headless Chrome manually

This is easiest using npx and tooling provided by Puppeteer (depends on node/npm, but it's worth it). This installs chrome in a `chrome` folder in the current working dir and it outputs the path where it's installed when it's finished. Currently we'd advise for the `chrome-headless-shell` variant that is a light version meant just for this use case. The chrome-headless-shell is a minimal, headless version of the Chrome browser designed specifically for environments where you need to run Chrome without a graphical user interface (GUI). This is particularly useful in scenarios like server-side rendering, automated testing, web scraping, or any situation where you need the power of the Chrome browser engine without the overhead of displaying a UI. Headless by design, reduced size and overhead but still the same engine.

```sh
npx @puppeteer/browsers install chrome-headless-shell@stable
```

It installs to a path like this `./chrome-headless-shell/mac_arm-128.0.6613.84/chrome-headless-shell-mac-arm64/chrome-headless-shell`. As it's headless by design, it only needs one parameter:

```sh
./chrome-headless-shell/mac_arm-128.0.6613.84/chrome-headless-shell-mac-arm64/chrome-headless-shell --remote-debugging-port=9222
```
*Note: Seems the august 2024 release Chrome releases 128.0.6613.85 onward is seriously performance impacted for PDF generation. Chrome Headless Shell releases don't seem to suffer from this issue.

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
- [Radu Bogoevici](https://github.com/codenighter) - Thanks for test driving, and all help big and small.

## Findings

- For Chrome, mode headless=new seems to be slower for pdf rendering cases.
- On mac m3 (aug 24), chromium (brew install chromium) is about 3x slower then chrome? Maybe the chromium that get's installed is not ARM optimized?

## Primitive benchmark

On a macbook m3, the throughput for 'hello world' PDF generation can reach around 500 to 800 docs/second when allowing for some concurrency (4 threads). As Chrome is actually also very efficient, it scales really well for complex documents also. If you run this in Rails, the concurrency is being taken care of either by the front end thread pool or by the workers and you shouldn't have to think about this. (Using an external Chrome)

Note: it renders `"Hello #{i}, world #{j}! #{Time.now}."` where i is the thread and j is the iteration counter within the thread and persists it to an SSD (which is very fast these days).

```sh
c:1, n:10 : Throughput = 16.76 docs/sec, Total time = 0.5968 seconds
c:2, n:10 : Throughput = 170.41 docs/sec, Total time = 0.1174 seconds
c:4, n:80 : Throughput = 579.03 docs/sec, Total time = 0.5526 seconds```
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

TODO

```Dockerfile
# Install Nodejs and Chromium, to import the chrome headless shell dependencies easily (chrome itself is not used)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install --no-install-recommends -y nodejs chromium && \
    rm -rf /var/lib/apthet/lists /var/cache/apt/archives

# Install Chrome Headless Shell
RUN npx --yes @puppeteer/browsers install chrome-headless-shell@stable
```

Use a script like the below, to launch chrome headless shell from e.g. docker entrypoint script.

*launch_chrome_headless_shell.rb*

```sh
#!/bin/bash
# find the installation path of chrome headless shell (latest version)
export CHROME_PATH=$(npx --yes @puppeteer/browsers install chrome-headless-shell@stable | awk '{print $2}')
# start chrome headless with remote debugging on
$CHROME_PATH --disable-gpu --remote-debugging-port=9222 --disable-software-rasterizer --disable-bluetooth --no-sandbox
```

*It has also been reported that the Chrome process repeatedly crashes when running inside a Docker container on an M1 Mac. Chrome should work asexpected when deployed to a Docker container on a non-M1 Mac.*


## Thread-safety

For performance reasons, the code uses a low level websocket connection that does all it's work on the curent thread
so we can avoid synchronisation penalties.

Behind the scenes, a websocket is openend and stored on Thread.current for subsequent requests. Hence, the code is
thread safe in the sense that every web socket get's a new tab in the underlying chromium and get an isolated context.

## Heroku

TODO

This buildpack installs chrome and chromedriver (chromedriver is actually not needed, but at least the buildpack is maintained)

```sh
https://github.com/heroku/heroku-buildpack-chrome-for-testing
```

### launch as child process

This is the current default. If HEROKU is detected, then we set `HEADLESS_CHROME_PATH=chrome` as an ENV variable as the above buildpack adds `chrome` to the path. Basically it should run out of the box as long as the buildpack is added.

### run seperately

If you prefer to run it next to your Rails app, then in your `Procfile` adjust the web worker command to

```yaml
web: bin/start
```

And create a bin/start script

```sh
#!/bin/bash
# Start Rails app
bundle exec rails server -p $PORT -e $RAILS_ENV &

# Start the background app
command_to_start_your_background_app &

# Wait for all processes to finish
wait -n
```

Ensure the script is executable

```sh
chmod +x bin/start
```
