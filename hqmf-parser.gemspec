# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hqmf-parser"
  s.summary = "A library for parsing HQMF XML files."
  s.description = "A library for parsing HQMF XML files."
  s.email = "talk@projectpophealth.org"
  s.homepage = "http://github.com/pophealth/hqmf-parser"
  s.authors = ["Adam Goldstein", "Andre Quina", "Marc Hadley"]
  s.version = '0.0.1'
  
  s.add_dependency 'rubyzip'
  s.add_dependency 'spreadsheet'
  s.add_dependency 'google-spreadsheet-ruby'
  s.add_dependency 'roo'

  s.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.rake') + ["Gemfile", "README.md", "Rakefile", "VERSION"]

end
