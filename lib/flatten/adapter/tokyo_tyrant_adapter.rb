require 'tokyo_tyrant'
require File.join(File.dirname(__FILE__), 'abstract_tokyo_adapter')

module Flatten
  module Adapter
    class TokyoTyrantAdapter < AbstractTokyoAdapter
      def initialize(options = {})
        @database = TokyoTyrant::DB.new(
          options[:host] || 'localhost',
          options[:port] || 1978
        )
      end
    end
  end
end
