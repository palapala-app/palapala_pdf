# frozen_string_literal: true

require_relative "test_helper"
require "benchmark"

class TestPdf < Minitest::Test
  def setup
  end

  def test_create_pdf_from_html
    # Create a page
    pdf = Palapala::Pdf.new("<h1>Hello, world! #{Time.now}</h1>")

    # Create a PDF from the HTML content
    binary_data = pdf.binary_data

    # Validate the PDF content
    assert binary_data.start_with?("%PDF-1.4")
  end
end
