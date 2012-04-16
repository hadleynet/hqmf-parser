require 'cover_me'
require 'bundler/setup'
require 'test/unit'
require 'turn'

# Load project files
PROJECT_ROOT = File.expand_path("../../", __FILE__)
require_relative File.join(PROJECT_ROOT, 'lib', 'hqmf-parser')

