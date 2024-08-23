# frozen_string_literal: true

require 'singleton'

class Controller
  include Singleton

  def initialize
    if running_in_rails?
      setup_rails_integration
    else
      puts 'Not running in Rails'
    end
  end

  def running_in_rails?
    defined?(Rails) && Rails.respond_to?(:application)
  end

  def setup_rails_integration
    # Define a controller dynamically
    create_rails_controller
    # Optionally, add routes dynamically
    add_rails_routes
  end

  def create_rails_controller
    # Dynamically define a Rails controller
    controller = Class.new(ActionController::Base) do
      @@files = {}

      def serve
        file_key = params[:key]

        if @@files.key?(file_key)
          send_data @@files[file_key], type: 'application/octet-stream', disposition: 'inline'
        else
          render plain: 'File not found', status: :not_found
        end
      end

      def self.add_file(content)
        key = SecureRandom.uuid
        @@files[key] = content
        key
      end

      def self.remove_file(key)
        @@files.delete(key)
      end
    end

    # Assign it to a constant for Rails to recognize
    Object.const_set('MemoryFilesController', controller)
  end

  def add_rails_routes
    Rails.application.routes.draw do
      get 'file/:key', to: 'memory_files#serve', as: :serve_memory_file
    end
  end
end

Controller.instance
