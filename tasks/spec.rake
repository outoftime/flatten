require 'spec/rake/spectask'

desc 'Run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts << '--color'
end

namespace :spec do
  desc 'Run specs for all environment options'
  task :all do
    %w(FILE TOKYO_CABINET TOKYO_TYRANT).each do |adapter|
      fork do
        ENV['ADAPTER'] = adapter
        Rake::Task[:spec].invoke
      end
      Process.wait
    end
  end
end
