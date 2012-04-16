require 'rake'
require 'rake/testtask'

require_relative File.join('lib', 'hqmf-parser')

# Pull in any rake task defined in lib/tasks
Dir['lib/tasks/*.rake'].sort.each do |ext|
  load ext
end

$LOAD_PATH << File.expand_path("../test",__FILE__)
desc "Run basic tests"
Rake::TestTask.new("test_unit") { |t|
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = true
  t.warning = true
}

task :default => [:test_unit,'cover_me:report']