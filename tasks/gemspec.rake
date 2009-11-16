require 'jeweler'

Jeweler::Tasks.new do |s|
  s.name = 'flatten'
  s.summary = 'Publish complex objects as structured data and reconstitute them for fast read'
  s.email = 'mat@patch.com'
  s.homepage = 'http://github.com/outoftime/flatten'
  s.description = 'Publish complex objects as structured data and reconstitute them for fast read'
  s.authors = ['Mat Brown']
  s.files = FileList['[A-Z]*', '{lib,spec}/**/*']
  s.add_runtime_dependency 'careo-tokyocabinet'
  s.add_development_dependency 'rspec', '~> 1.1.12'
end
