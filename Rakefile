require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/record_select/version.rb'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "recordselect_vho"
  gem.version = RecordSelect::Version::STRING
  gem.homepage = "http://github.com/vhochstein/recordselect"
  gem.license = "MIT"
  gem.summary = %Q{RecordSelect widget as a replacement for massive drop down lists}
  gem.description = %Q{RecordSelect is a Rails widget to help you pick one record out of many. I designed it as a more usable and performant alternative to generating a massive dropdown list}
  gem.email = "activescaffold@googlegroups.com"
  gem.authors = ["Volker Hochstein", "Lance Ivy"]
  gem.add_runtime_dependency 'rails', '~> 3.0.0'
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rake/rdoctask'
desc 'Generate documentation for the recordselect plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Recordselect #{RecordSelect::Version::STRING}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('assets/**/*.js')
end

task :default => :test