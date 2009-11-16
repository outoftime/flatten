using_gems = false
begin
  require 'spec'
  require 'ruby-debug'
rescue LoadError => e
  if using_gems
    raise(e)
  else
    using_gems = true
    require 'rubygems'
    retry
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'flatten')

Dir.glob(File.join(File.dirname(__FILE__), 'mocks', '**', '*.rb')).each do |filename|
  require filename
end

adapter = ENV['ADAPTER'] ||= 'FILE'
STDERR.puts("Using adapter #{adapter}")
data_dir = File.join(File.dirname(__FILE__), 'data', adapter.downcase)
FileUtils.rm_r(Dir.glob(File.join(data_dir, '*')))
FileUtils.mkdir_p(data_dir)
case adapter
when 'FILE'
  Flatten.adapter = Flatten::Adapter::FileAdapter.new(data_dir)
when 'TOKYO_CABINET'
  Flatten.adapter = Flatten::Adapter::TokyoCabinetAdapter.new(
    File.join(data_dir, 'test.tch')
  )
end
