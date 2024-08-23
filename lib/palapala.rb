# frozen_string_literal: true

require_relative 'palapala/pdf'

# Main module for the gem
module Palapala
  def self.setup
    yield self
  end

  def self.ferrum_opts=(ferrum_opts)
    @ferrum_opts = ferrum_opts
  end

  def self.ferrum_opts
    @ferrum_opts
  end

  def self.defaults=(defaults)
    @defaults = defaults
  end

  def self.defaults
    @defaults ||= {}
  end
end
