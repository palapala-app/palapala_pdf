require_relative "./renderer"

module Palapala
  # Page class to generate PDF from HTML content using Chrome in headless mode in a thread-safe way
  # @param page_ranges Empty string means all pages, e.g., "1-3, 5, 7-9"
  class Pdf
    # Initialize the PDF object with the HTML content and optional parameters.
    #
    # The options are passed to the renderer when generating the PDF.
    # The options are the snakified version of the options from the Chrome DevTools Protocol to respect the Ruby conventions.
    # (see https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF)
    #
    # @param content [String] the HTML content to convert to PDF
    # @param footer_html [String] the HTML content for the footer
    # @param footer [String] the footer content that is centered
    # @param generate_tagged_pdf [Boolean] whether to generate a tagged PDF
    # @param header_html [String] the HTML content for the header
    # @param header [String] the header content that is centered
    # @param landscape [Boolean] whether to use landscape orientation
    # @param margin_bottom [Integer] the bottom margin in inches
    # @param margin_left [Integer] the left margin in inches
    # @param margin_right [Integer] the right margin in inches
    # @param margin_top [Integer] the top margin in inches
    # @param page_ranges [String] the page ranges to print, e.g., "1-3, 5, 7-9"
    # @param paper_height [Integer] the paper height in inches
    # @param paper_width [Integer] the paper width in inches
    # @param prefer_css_page_size [Boolean] whether to prefer CSS page size (advised)
    # @param print_background [Boolean] whether to print background graphics
    # @param scale [Float] the scale of the PDF rendering
    def initialize(content,
                   footer_template: nil,
                   footer: nil,
                   generate_tagged_pdf: nil,
                   header_template: nil,
                   header: nil,
                   landscape: nil,
                   margin_bottom: nil,
                   margin_left: nil,
                   margin_right: nil,
                   margin_top: nil,
                   page_ranges: nil,
                   paper_height: nil,
                   paper_width: nil,
                   prefer_css_page_size: nil,
                   print_background: nil,
                   scale: nil,
                   watermark: nil)
      @content = content || raise(ArgumentError, "Content is required and can't be nil")
      @opts = {}
      raise(ArgumentError, "Either footer or footer_template is expected") if !footer_template.nil? && !footer.nil?
      raise(ArgumentError, "Either header or header_template is expected") if !header_template.nil? && !header.nil?
      @opts[:headerTemplate]      = header_template      || hf_template(from: header) || Palapala.defaults[:header_template]
      @opts[:footerTemplate]      = footer_template      || hf_template(from: footer) || Palapala.defaults[:footer_template]
      @opts[:pageRanges]          = page_ranges          || Palapala.defaults[:page_ranges]
      @opts[:generateTaggedPDF]   = generate_tagged_pdf  || Palapala.defaults[:generate_tagged_pdf]
      @opts[:paperWidth]          = paper_width          || Palapala.defaults[:paper_width]
      @opts[:paperHeight]         = paper_height         || Palapala.defaults[:paper_height]
      @opts[:landscape]           = landscape            || Palapala.defaults[:landscape]
      @opts[:marginTop]           = margin_top           || Palapala.defaults[:margin_top]
      @opts[:marginLeft]          = margin_left          || Palapala.defaults[:margin_left]
      @opts[:marginBottom]        = margin_bottom        || Palapala.defaults[:margin_bottom]
      @opts[:marginRight]         = margin_right         || Palapala.defaults[:margin_right]
      @opts[:preferCSSPageSize]   = prefer_css_page_size || Palapala.defaults[:prefer_css_page_size]
      @opts[:printBackground]     = print_background     || Palapala.defaults[:print_background]
      @opts[:scale]               = scale                || Palapala.defaults[:scale]
      @opts[:headerTemplate]      = (@opts[:headerTemplate].to_s + watermark(watermark)) if watermark
      @opts[:displayHeaderFooter] = (@opts[:headerTemplate] || @opts[:footerTemplate]) ? true : false
      @opts[:encoding]            = :binary
      @opts.compact!
    end

    def watermark(watermark, angle: "-15deg", color: "rgba(25,25,25,0.25)")
      <<~HTML
        <style>
          .palapala_pdf_watermark {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(#{angle});
            font-size: 72pt;
            color: #{color};
            z-index: 9999;
          }
        </style>
        <span class="palapala_pdf_watermark">#{watermark}</span>
      HTML
    end

    def hf_template(from:)
      return if from.nil?
      style = <<~HTML.freeze
        <style>
          #header, #footer {
            font-size: 10pt;
            display: flex;
            justify-content: center;
          }
        </style>
      HTML
      style + from
    end

    # Render the PDF content to a binary string.
    #
    # The params from the initializer are converted to the expected casing and merged with the options passed to this method.
    # The options passed here are passed unchanged to the renderer and get priority over the options from the initializer.
    # Chrome DevTools Protocol expects the options to be camelCase, see https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF.
    #
    # @param opts [Hash] the options to pass to the renderer
    # @return [String] the PDF content as a binary string
    def binary_data
      puts "Rendering PDF with params: #{@opts}" if Palapala.debug
      Renderer.html_to_pdf(@content, params: @opts)
    rescue StandardError => e
      puts "Error rendering PDF: #{e.message}"
      Renderer.reset
      raise
    end


    # Save the PDF content to a file
    # @param path [String] the path to save the PDF file
    # @return [void]
    def save(path)
      File.binwrite(path, binary_data)
    end
  end
end
