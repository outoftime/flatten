%w(collection resource document adapter).each { |filename| require File.join(File.dirname(__FILE__), 'flatten', filename) }

module Flatten
  class <<self
    attr_accessor :adapter
  end
end
