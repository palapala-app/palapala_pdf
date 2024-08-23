# frozen_string_literal: true

class DynamicFileServer
  CONTENT_TYPE = 'text/html' # "application/octet-stream"

  @@files = {} # Shared storage for files

  def initialize(port: 9223)
    if running_in_rails?
      setup_rails_integration
    else
      setup_webrick_server(port)
    end
  end

  # Add a file to the server
  def add_file(content)
    file_key = SecureRandom.uuid
    @@files[file_key] = content
    file_key
  end

  # Remove a file from the server
  def remove_file(file_key)
    @@files.delete(file_key)
  end

  # Class method to access the shared files
  def self.files
    @@files
  end

  private

  def running_in_rails?
    defined?(Rails) && Rails.respond_to?(:application)
  end

  def setup_rails_integration
    create_rails_controller
    add_rails_routes
  end

  def setup_webrick_server(port)
    @server = WEBrick::HTTPServer.new(Port: port)

    @server.mount_proc '/file' do |req, res|
      file_key = req.path.sub('/file/', '')

      if @@files.key?(file_key)
        res.status = 200
        res['Content-Type'] = CONTENT_TYPE
        res.body = @@files[file_key]
      else
        res.status = 404
        res.body = 'File not found'
      end
    end

    @server_thread = Thread.new { @server.start }
  end

  def create_rails_controller
    controller = Class.new(ActionController::Base) do
      def serve
        file_key = params[:key]

        if DynamicFileServer.files.key?(file_key)
          send_data DynamicFileServer.files[file_key], type: 'application/octet-stream', disposition: 'inline'
        else
          render plain: 'File not found', status: :not_found
        end
      end
    end

    Object.const_set('MemoryFilesController', controller)
  end

  def add_rails_routes
    Rails.application.routes.draw do
      get 'file/:key', to: 'memory_files#serve', as: :serve_memory_file
    end
  end
end
