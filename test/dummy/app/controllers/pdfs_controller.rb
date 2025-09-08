class PdfsController < ApplicationController
  def index
  end

  def show
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: {},
        disposition: :inline,
        filename: "example.pdf"
      }
    end
  end

  def url
    respond_to do |format|
      format.pdf { render pdf: { url: params[:url] }, disposition: :inline, filename: "example.pdf" }
    end
  end
end
