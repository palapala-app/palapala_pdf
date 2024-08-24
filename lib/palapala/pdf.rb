require 'ferrum'

module Palapala
  # Page class to generate PDF from HTML content using Chrome in headless mode in a thread-safe way
  # @param page_ranges Empty string means all pages, e.g., "1-3, 5, 7-9"
  class PDF
    def initialize(content = nil,
                   url: nil,
                   header_html: nil,
                   footer_html: nil,
                   generate_tagged_pdf: Palapala.defaults.fetch(:generate_tagged_pdf, false),
                   prefer_css_page_size: Palapala.defaults.fetch(:prefer_css_page_size, true),
                   scale: Palapala.defaults.fetch(:scale, 1),
                   page_ranges: Palapala.defaults.fetch(:page_ranges, nil),
                   margin: Palapala.defaults.fetch(:margin, {}))
      @content = content
      @url = url
      @header_html = header_html
      @footer_html = footer_html
      @generate_tagged_pdf = generate_tagged_pdf
      @prefer_css_page_size = prefer_css_page_size
      @page_ranges = page_ranges
      @scale = scale
      @margin = margin
    end

    def binary_data(**opts)
      pdf(**opts)
    end

    def save(path, **opts)
      pdf(path:, **opts)
    end

    private

    def pdf(**opts)
      browser_context = browser.contexts.create
      browser_page = browser_context.page
      debug(browser_page) if Palapala.debug
      browser_page.go_to(url)
      pdf_binary_data = browser_page.pdf(**merged_opts(opts))
      opts[:path] || pdf_binary_data
    ensure
      browser_context.dispose
    end

    def browser
      # According to the docs ferrum is thread safe, however, under heavy load
      # we are seeing some issues, so we are using thread locals to have a
      # browser per thread
      Thread.current[:browser] ||= Ferrum::Browser.new(Palapala.ferrum_opts)
    end

    def url
      if @content
      encoded_html = Base64.strict_encode64(@content)
        "data:text/html;base64,#{encoded_html}"
      elsif @url
        @url
      else
        raise ArgumentError, "Either 'content' or 'url' must be provided"
      end
    end

    def merged_opts(opts)
      result = {
        scale: @scale,
        printBackground: true,
        dispayHeaderFooter: true,
        encoding: :binary,
        preferCSSPageSize: @prefer_css_page_size
      }
      result[:headerTemplate]    = @header_html         unless @header_html.nil?
      result[:footerTemplate]    = @footer_html         unless @footer_html.nil?
      result[:pageRanges]        = @page_ranges         unless @page_ranges.nil?
      result[:path]              = @path                unless @path.nil?
      result[:generateTaggedPDF] = @generate_tagged_pdf unless @generate_tagged_pdf.nil?
      result[:format]            = @format              unless @format.nil?
      resultts[:paperWidth]        = @paper_width         unless @paper_width.nil?
      resultts[:paperHeight]       = @paper_height        unless @paper_height.nil?
      result[:landscape]         = @landscape           unless @landscape.nil?
      result[:marginTop]         = @margin[:top]        unless @margin[:top].nil?
      result[:marginLeft]        = @margin[:left]       unless @margin[:left].nil?
      result[:marginBottom]      = @margin[:bottom]     unless @margin[:bottom].nil?
      result[:marginRight]       = @margin[:right]      unless @margin[:right].nil?

      result.merge(opts)

      puts "opts: #{opts}" if Palapala.debug
      opts
    end

    def debug(browser_page)
      browser_page.on('Runtime.consoleAPICalled') do |params|
        params['args'].each { |r| puts(r['value']) }
      end
    end
  end
end
