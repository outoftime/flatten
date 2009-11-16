%w(resource document adapter).each { |filename| require File.join(File.dirname(__FILE__), 'flatten', filename) }

module Flatten
end

class <<Flatten
  attr_accessor :adapter
end
