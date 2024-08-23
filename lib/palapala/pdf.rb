# frozen_string_literal: true

require 'ferrum'

module Palapala
  # Page class to generate PDF from HTML content using Chrome in headless mode in a thread-safe way
  class Page
    def initialize(content = nil,
                   url: nil,
                   path: nil,
                   header_html: nil,
                   footer_html: nil,
                   generate_tagged_pdf: false,
                   prefer_css_page_size: true,
                   scale: Palapala.defaults.fetch(:scale, 1),
                   page_ranges: Palapala.defaults.fetch(:page_ranges, ''),
                   margin: Palapala.defaults.fetch(:margin, {}))
      @content = content
      @url = url
      @path = path
      @header_html = header_html
      @footer_html = footer_html
      @generate_tagged_pdf = generate_tagged_pdf
      @prefer_css_page_size = prefer_css_page_size
      @page_ranges = page_ranges
      @scale = scale
      @margin = margin
    end

    def pdf(**opts)
      browser_context = browser.contexts.create
      browser_page = browser_context.page
      # # output console logs for this page
      if opts[:debug]
        browser_page.on('Runtime.consoleAPICalled') do |params|
          params['args'].each { |r| puts(r['value']) }
        end
      end
      # open the page
      url = @url || data_url
      browser_page.go_to(url)
      # Wait for the page to load
      browser_page.network.wait_for_idle
      # Generate PDF
      pdf_binary_data = browser_page.pdf(**opts_with_defaults.merge(opts))
      # Dispose the context
      browser_context.dispose
      # Return the PDF data
      pdf_binary_data
    end

    def binary_data(**opts)
      pdf(**opts)
    end

    def save(path, **opts)
      pdf(path:, **opts)
    end

    private

    def data_url
      encoded_html = Base64.strict_encode64(@content)
      "data:text/html;base64,#{encoded_html}"
    end

    def opts_with_defaults
      opts = { scale: @scale,
               printBackground: true,
               dispayHeaderFooter: true,
               pageRanges: @page_ranges, # Empty string means all pages, e.g., "1-3, 5, 7-9"
               encoding: :binary,
               preferCSSPageSize: true,
               headerTemplate: @header_html || '',
               footerTemplate: @footer_html || '' }

      opts[:path] = @path unless @path.nil?
      opts[:generateTaggedPDF] = @generate_tagged_pdf unless @generate_tagged_pdf.nil?
      opts[:format] = @format unless @format.nil?
      opts[:paperWidth] = @paper_width unless @paper_width.nil?
      opts[:paperHeight] = @paper_height unless @paper_height.nil?
      opts[:landscape] = @landscape unless @landscape.nil?
      opts[:marginTop] = @margin[:top] unless @margin[:top].nil?
      opts[:marginLeft] = @margin[:left] unless @margin[:left].nil?
      opts[:marginBottom] = @margin[:bottom] unless @margin[:bottom].nil?
      opts[:marginRight] = @margin[:right] unless @margin[:right].nil?

      opts
    end

    def browser
      # accordng to the docs ferrum is thread safe, however, under heavy load
      # we are seeing some issues, so we are using thread locals to have a
      # browser per thread
      Thread.current[:browser] ||= new_browser
      # @@browser ||= new_browser
    end

    def new_browser
      Ferrum::Browser.new(Palapala.ferrum_opts)
    end

    # # TODO use method from template class
    # def cm_to_inches(value)
    #   value / 2.54
    # end
  end
end
