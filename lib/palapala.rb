require_relative 'palapala/pdf'

module Palapala
  def self.setup
    yield self
  end

  class << self
    attr_accessor :ferrum_opts
    attr_accessor :defaults
    attr_accessor :debug
  end

  self.ferrum_opts = {}
  self.defaults = {}
  self.debug = false
end
