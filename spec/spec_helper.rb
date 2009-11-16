require 'rubygems'
require 'spec'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), '..', 'lib', 'flatten')

Dir.glob(File.join(File.dirname(__FILE__), 'mocks', '**', '*.rb')).each do |filename|
  require filename
end

data_dir = File.join(File.dirname(__FILE__), 'data')
FileUtils.rm_r(Dir.glob(File.join(data_dir, '*')))
Flatten.adapter = Flatten::Adapter::FileAdapter.new(data_dir)
