module Flatten
  module Adapter
    AdapterError = Class.new(StandardError)

    autoload :FileAdapter, File.join(File.dirname(__FILE__), 'adapter', 'file_adapter.rb')
    autoload :TokyoCabinetAdapter, File.join(File.dirname(__FILE__), 'adapter', 'tokyo_cabinet_adapter.rb')
  end
end
