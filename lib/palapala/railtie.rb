module Palapala
  class Railtie < ::Rails::Railtie
    initializer "palapala_pdf.assets_helper" do
      ActiveSupport.on_load(:action_view) do
        include Palapala::AssetsHelper
      end
    end

    initializer "ferrum_pdf.controller" do
      ActiveSupport.on_load(:action_controller) do
        # render pdf: { pdf options }, template: "whatever", disposition: :inline, filename: "example.pdf"
        ActionController.add_renderer :pdf do |pdf_options, options|
          send_data_options = options.extract!(:disposition, :filename, :status)
          url = pdf_options.delete(:url)
          html = render_to_string(**options.with_defaults(formats: [ :html ])) if url.blank?
          base_url = request.base_url
          processed_html = Palapala::HTMLPreprocessor.process(html, base_url)
          pdf = Palapala::Pdf.new(processed_html).binary_data
          send_data(pdf, **send_data_options.with_defaults(type: :pdf))
        end
      end
    end
  end
end
