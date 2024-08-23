# frozen_string_literal: true

require_relative 'lib/palapala_pdf/version'

Gem::Specification.new do |spec|
  spec.name = 'palapala_pdf'
  spec.version = HtmlPdfChrome::VERSION
  spec.authors = ['Koen Handekyn']
  spec.email = ['github.com@handekyn.com']

  spec.summary = 'Convert HTML into PDF directly from Ruby using Chrome/Chromium.'
  spec.description = 'This gem uses Ferrum to render HTML into a PDF using Chrom(e)(ium) with minimal dependencies.'
  spec.homepage = 'https://github.com/palapala-app/palapala_pdf'
  spec.required_ruby_version = '>= 3.1'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/palapala-app/palapala_pdf'
  spec.metadata['changelog_uri'] = 'https://github.com/palapala-app/palapala_pdf/blob/main/changelog.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ draft/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'ferrum' # , "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end