# frozen_string_literal: true

require_relative 'html_pdf_chrome/page'

# Main module for the gem
module HtmlPdfChrome
  def self.setup
    yield self
  end

  def self.ferrum_opts=(ferrum_opts)
    @ferrum_opts = ferrum_opts
  end

  def self.ferrum_opts
    @ferrum_opts
  end

  def self.defaults=(defaults)
    @defaults = defaults
  end

  def self.defaults
    @defaults ||= {}
  end
end
