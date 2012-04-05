require 'cover_me'
require 'rake'
require 'rake/testtask'
require 'pry'

# Pull in any rake task defined in lib/tasks
Dir['lib/tasks/*.rake'].sort.each do |ext|
  load ext
end

PROJECT_ROOT = File.expand_path("../", __FILE__)
require_relative File.join(PROJECT_ROOT, 'lib', 'hqmf-parser')

Rake::TestTask.new(:test_unit) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :test => [:test_unit] do
  CoverMe.complete!
end