gem 'rspec', '~> 1.1.12'
require 'spec/rake/spectask'

desc 'Run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
