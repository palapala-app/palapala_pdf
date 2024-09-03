module Palapala
  module Helper
    def self.header(left: "", center: "", right: "", margin: "1cm")
      <<~HTML
        <div style="display: flex; justify-content: space-between; width: 100%; margin-left: #{margin}; margin-right: #{margin};">
          <div style="text-align: left; flex: 1;">#{left}</div>
          <div style="text-align: center; flex: 1;">#{center}</div>
          <div style="text-align: right; flex: 1;">#{right}</div>
      </div>
      HTML
    end

    def self.footer(left: "", center: "", right: "", margin: "1cm")
      self.header(left:, center:, right:, margin:)
    end
``
    def self.page_number
      <<~HTML
        <span class="pageNumber"></span>/<span class="totalPages"></span>
      HTML
    end

    def self.watermark(watermark, angle: "-15deg", color: "rgba(25,25,25,0.25)", font_size: "72pt")
      <<~HTML
        <style>
          .palapala_pdf_watermark {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(#{angle});
            font-size: #{font_size};
            color: #{color};
            z-index: 9999;
          }
        </style>
        <span class="palapala_pdf_watermark">#{watermark}</span>
      HTML
    end

    def self.hf_template(from:)
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
  end
end
