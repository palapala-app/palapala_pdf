# frozen_string_literal: true

module Palapala
  # Page class to generate PDF from HTML content using Chrome in headless mode in a thread-safe way
  # @param page_ranges Empty string means all pages, e.g., "1-3, 5, 7-9"
  class Pdf
    def initialize(content = nil,
                   header_html: nil,
                   footer_html: nil,
                   generate_tagged_pdf: Palapala.defaults.fetch(:generate_tagged_pdf, false),
                   prefer_css_page_size: Palapala.defaults.fetch(:prefer_css_page_size, true),
                   scale: Palapala.defaults.fetch(:scale, 1),
                   page_ranges: Palapala.defaults.fetch(:page_ranges, nil),
                   margin: Palapala.defaults.fetch(:margin, {}))
      @content = content
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
      File.binwrite(path, pdf(**opts))
    end

    private

    def renderer
      Thread.current[:renderer] ||= Renderer.new
    end

    def pdf(**opts)
      puts "Rendering PDF with options: #{opts}" if Palapala.debug
      renderer.html_to_pdf(@content, params: opts_with_defaults.merge(opts))
    end

    def opts_with_defaults
      opts = { scale: @scale,
               printBackground: true,
               displayHeaderFooter: true,
               encoding: :binary,
               preferCSSPageSize: @prefer_css_page_size }

      opts[:headerTemplate] = @header_html unless @header_html.nil?
      opts[:footerTemplate] = @footer_html unless @footer_html.nil?
      opts[:pageRanges] = @page_ranges unless @page_ranges.nil?
      opts[:path] = @path unless @path.nil?
      opts[:generateTaggedPDF] = @generate_tagged_pdf unless @generate_tagged_pdf.nil?
      opts[:format] = @format unless @format.nil?
      # opts[:paperWidth] = @paper_width unless @paper_width.nil?
      # opts[:paperHeight] = @paper_height unless @paper_height.nil?
      opts[:landscape] = @landscape unless @landscape.nil?
      opts[:marginTop] = @margin[:top] unless @margin[:top].nil?
      opts[:marginLeft] = @margin[:left] unless @margin[:left].nil?
      opts[:marginBottom] = @margin[:bottom] unless @margin[:bottom].nil?
      opts[:marginRight] = @margin[:right] unless @margin[:right].nil?
      opts
    end
  end
end
