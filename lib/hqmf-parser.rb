# require
require 'nokogiri'
require 'pry'
require 'json'

# require_relative
require_relative 'hqmf-model/utilities.rb'

require_relative 'hqmf-parser/1.0/utilities'
require_relative 'hqmf-parser/1.0/range'
require_relative 'hqmf-parser/1.0/document'
require_relative 'hqmf-parser/1.0/data_criteria'
require_relative 'hqmf-parser/1.0/attribute'
require_relative 'hqmf-parser/1.0/population_criteria'
require_relative 'hqmf-parser/1.0/precondition'
require_relative 'hqmf-parser/1.0/restriction'
require_relative 'hqmf-parser/1.0/comparison'
require_relative 'hqmf-parser/1.0/expression'

require_relative 'hqmf-parser/2.0/utilities'
require_relative 'hqmf-parser/2.0/types'
require_relative 'hqmf-parser/2.0/document'
require_relative 'hqmf-parser/2.0/data_criteria'
require_relative 'hqmf-parser/2.0/population_criteria'
require_relative 'hqmf-parser/2.0/precondition'

require_relative 'hqmf-parser/converter/document_converter'
require_relative 'hqmf-parser/converter/data_criteria_converter'
require_relative 'hqmf-parser/converter/population_criteria_converter'
require_relative 'hqmf-parser/converter/precondition_converter'
require_relative 'hqmf-parser/converter/restriction_converter'

require_relative 'hqmf-model/data_criteria.rb'
require_relative 'hqmf-model/document.rb'
require_relative 'hqmf-model/population_criteria.rb'
require_relative 'hqmf-model/precondition.rb'
require_relative 'hqmf-model/types.rb'
require_relative 'hqmf-model/attribute.rb'

require_relative 'hqmf-parser/value_sets/value_set_parser'

require_relative 'hqmf-parser/parser'
