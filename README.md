# PDF Generation for your Rubies

This project is a Ruby gem that provides functionality for generating PDF files from HTML using the Chrome browser. It allows you to easily convert HTML content into PDF documents, making it convenient for tasks such as generating reports, invoices, or any other printable documents. The gem provides a simple and intuitive API for converting HTML to PDF, and it leverages the power and flexibility of the Chrome browser's rendering engine to ensure accurate and high-quality PDF output. With this gem, you can easily integrate PDF generation capabilities into your Ruby applications.

At the core, this project leverages the same rendering engine as [Grover](https://github.com/Studiosity/grover), but with significantly reduced overhead and dependencies. Instead of relying on the full Grover stack, this project builds on [Ferrum](https://github.com/rubycdp/ferrum) to enable direct communication from Ruby to a headless Chrome or Chromium browser. This approach ensures efficient, thread-safe operations, providing a streamlined alternative for rendering tasks without sacrificing performance or flexibility.

## Installation

To install the gem and add it to your application's Gemfile, execute the following command:

```
$ bundle add palapala_pdf
```

If you are not using bundler to manage dependencies, you can install the gem by running:

```
$ gem install palapala_pdf
```

## Usage Instructions

To create a PDF from HTML content using the `Palapala` library, follow these steps:

1. **Setup Configuration**:

Configure the `Palapala` library with the necessary options, such as the URL for the Ferrum browser and default settings like scale and format.

In a Rails context, this could be inside an initializer.

```ruby
Palapala.setup do |config|
    config.ferrum_opts = { url: 'http://localhost:9222' }
    config.defaults = { scale: 1, format: :A4 }
end
```

2. **Create a PDF from HTML**:

Instantiate a new Palapala::Page object with your HTML content and generate the PDF binary data.

```ruby
page = Palapala::Page.new("<h1>Hello, world! #{Time.now}</h1>")
pdf = page.binary_data
```

Alternatively, write the pdf straight to a file:

```ruby
Palapala::Page.new("<h1>Hello, world! #{Time.now}</h1>").save("hello.pdf")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

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
