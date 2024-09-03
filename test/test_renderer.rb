# frozen_string_literal: true

require_relative "test_helper"
require "benchmark"

class TestPdf < Minitest::Test
  def setup
  end

  def test_create_pdf_from_html
    Palapala.debug = true
    Palapala::Renderer.ping
  end
end
