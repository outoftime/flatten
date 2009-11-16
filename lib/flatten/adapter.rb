%w(file_adapter).each { |filename| require File.join(File.dirname(__FILE__), 'adapter', filename) }

module Flatten
  module Adapter
  end
end
