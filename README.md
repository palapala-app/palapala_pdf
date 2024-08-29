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

If you are not using bundler to manage dependencies, you can install the gem by running:

```
$ gem install palapala_pdf
```

### Examples

#### Headers and Footers

TODO explain about headers and footers, font sizes, styles being independent, and how to insert current page, total pages, etc.

#### Page sizes and margins

Paged CSS, also known as @page CSS, is used to control the layout and appearance of printed documents. It allows you to define page-specific styles, such as sizes and margins, which are crucial for generating well-formatted PDFs.

You can specify the size of the page using predefined sizes or custom dimensions. Common predefined sizes include A4, A3, letter, etc.

Margins can be set for the top, right, bottom, and left sides of the page. You can specify all four margins at once or individually.

You can also define named pages for different sections of your document.

##### Example: A4 Page Size

```css
@page {
  size: A4;
}
```

##### Example: Custom Page Size

```css
@page {
  size: 8.5in 11in; /* Width x Height */
}
```

##### Example: Uniform Margins

```css
@page {
  margin: 1in; /* 1 inch on all sides */
}
```

##### Example: Individual Margins

```css
@page {
  margin: 1in 0.5in 1in 0.5in; /* Top, Right, Bottom, Left */
}
```

##### Example: Different First Page

```css
@page first {
  size: A4;
  margin: 2in; /* Larger margin for the first page */
}

@page {
  size: A4;
  margin: 1in;
}

body {
  counter-reset: page;
}

body:first {
  page: first;
}
```

###### Full Example

Here's a full example combining various aspects:

```css
@page {
  size: A4;
  margin: 1in;
}

@page landscape {
  size: A4 landscape;
  margin: 0.5in;
}

body {
  counter-reset: page;
}

body:first {
  page: first;
}

@page first {
  size: A4;
  margin: 2in;
}

h1 {
  page-break-before: always;
}
```

In this example:

- The default page size is A4 with 1-inch margins.
- A named page landscape is defined with A4 size in landscape orientation and 0.5-inch margins.
- The first page has a larger margin of 2 inches.
- The h1 elements will always start on a new page.
- These examples should help you get started with defining page sizes and margins using @page CSS for your PDF generation needs.

#### Page breaks

Paged CSS allows you to control how content is divided across pages when printing or generating PDFs. Page breaks are an essential part of this, as they determine where a new page starts. You can control page breaks using the `page-break-before`, `page-break-after`, and `page-break-inside` properties.

##### Page Break Properties

1. **`page-break-before`**: Forces a page break before the element.
2. **`page-break-after`**: Forces a page break after the element.
3. **`page-break-inside`**: Prevents or allows a page break inside the element.

##### Values

- `auto`: Default. Neither forces nor prevents a page break.
- `always` Always forces a page break.
- `avoid`: Avoids a page break inside the element.
- `left`: Forces a page break so that the next page is a left page.
- `right`: Forces a page break so that the next page is a right page.

##### Forcing a Page Break Before an Element

```css
h1 {
  page-break-before: always;
}
```

This ensures that every `h1` starts on a new page.

##### Forcing a Page Break After an Element

```css
p {
  page-break-after: always;
}
```

This ensures that every `p` element ends with a page break, starting the next content on a new page.

##### Avoiding Page Break Inside an Element

```css
table {
  page-break-inside: avoid;
}
```

This prevents a table from being split across two pages.

##### Full Example

Here's a full example combining various page break properties:

```css
@page {
  size: A4;
  margin: 1in;
}

h1 {
  page-break-before: always;
}

h2 {
  page-break-after: avoid;
}

table {
  page-break-inside: avoid;
}
```

In this example:
- Every `h1` element will start on a new page.
- `h2` elements will avoid causing a page break after them.
- Tables will avoid being split across pages.

##### Practical Use Cases

- **Chapter Titles**: Use `page-break-before: always;` for chapter titles to ensure each chapter starts on a new page.
- **Sections**: Use `page-break-after: always;` for sections that should end with a page break.
- **Tables and Figures**: Use `page-break-inside: avoid;` to keep tables and figures from being split across pages.

These properties help you control the layout of your printed documents or PDFs, ensuring that content is presented in a clear and organized manner.

#### Tables accross Pages

TODO `display` property with the values `table-header-group` and `table-footer-group`

##### Example

```html
<table>
  <thead>
    <tr>
      <th>Header 1</th>
      <th>Header 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Data 1</td>
      <td>Data 2</td>
    </tr>
    <!-- More rows -->
  </tbody>
  <tfoot>
    <tr>
      <td>Footer 1</td>
      <td>Footer 2</td>
    </tr>
  </tfoot>
</table>
```

In this example:
- The `<thead>` section will be repeated at the top of each page.
- The `<tfoot>` section will be repeated at the bottom of each page.

### Connecting to Chrome

TODO

Palapa PDF will go through this process

- check if a Chrome is running and exposing port 9222 (and if so, use it)
- if `Palapala.headless_chrome_path` is defined, launch Chrome as a child process using that path
- if **NPX** is avalaillable, install a **Chrome-Headless-Shell** variant locally and launch it as a child process. It will install the 'stable' version or the version identified by `Palapala.chrome_headless_shell_version` setting (or from ENV `CHROME_HEADLESS_SHELL_VERSION`).
- as a last fallback it will guess a chrome path from the detected OS and try to launch a Chrome with that

In our expreience a Chrome-Headless-Shell version gives the best performance and resource useage.

### Installing Chrome / Headless Chrome manually

This is easiest using npx and some tooling provided by Puppeteer. Unfortunately it depends on node/npm, but it's worth it. E.g. install a specific version like this:

```
npx @puppeteer/browsers install chrome@127.0.6533.88
````

This installs chrome in a `chrome` folder in the current working dir and it outputs the path where it's installed when it's finished which then could be started like this

Currently we'd advise for the `chrome-headless-shell` variant that is a light version meant just for this use case. The chrome-headless-shell is a minimal, headless version of the Chrome browser designed specifically for environments where you need to run Chrome without a graphical user interface (GUI). This is particularly useful in scenarios like server-side rendering, automated testing, web scraping, or any situation where you need the power of the Chrome browser engine without the overhead of displaying a UI. Headless by design, reduced size and overhead but still the same engine.

```
npx @puppeteer/browsers install chrome-headless-shell@stable
```

It installs to a path like this `./chrome-headless-shell/mac_arm-128.0.6613.84/chrome-headless-shell-mac-arm64/chrome-headless-shell`. As it's headless by design, it only needs one parameter:

```
./chrome-headless-shell/mac_arm-128.0.6613.84/chrome-headless-shell-mac-arm64/chrome-headless-shell --remote-debugging-port=9222
```

*Note: Seems the august 2024 release 128.0.6613.85 is seriously performance impacted. So to avoid regression issues, it's suggested to install a specific version of Chrome, test it and stick with it. The chrome-headless-shell does not seem to suffer from this though.*

### Installing Node/NPX

Using Brew

```
brew install node
```

Using NVM (Node Version Manager)

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.nvm/nvm.sh
nvm --version
nvm install node
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

*It has also been reported that the Chrome process repeatedly crashes when running inside a Docker container on an M1 Mac. Chrome should work as expected when deployed to a Docker container on a non-M1 Mac.*

## Thread-safety

For performance reasons, the code uses a low level websocket connection that does all it's work on the curent thread
so we can avoid synchronisation penalties.

Behind the scenes, a websocket is openend and stored on Thread.current for subsequent requests. Hence, the code is
thread safe in the sense that every web socket get's a new tab in the underlying chromium and get an isolated context.

## Heroku

TODO

possible buildpacks

https://github.com/heroku/heroku-buildpack-chrome-for-testing

this buildpack install chrome and chromedriver, which is actually not needed, but it's maintained

https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-google-chrome

this buildpack installs chrome, which is all we need, but it's deprecated
