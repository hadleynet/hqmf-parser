module HQMF
  # Class representing an HQMF document
  class Document

    include HQMF::JSON::Utilities

    attr_reader :title, :description, :measure_period
  
    # Create a new HQMF::Document which can be converted to JavaScript
    # @param [String] title
    # @param [String] description
    # @param [Array#PopulationCritera] population_criteria 
    # @param [Array#DataCriteria] data_criteria
    # @param [Range] measure_period
    def initialize(title, description, population_criteria, data_criteria, measure_period)
      @title = title
      @description = description
      @population_criteria = population_criteria
      @data_criteria = data_criteria
      @measure_period = measure_period
    end
    
    # Create a new HQMF::Document from a JSON hash keyed with symbols
    def self.from_json(json)
      title = json[:title]
      description = json[:description]

      population_criterias = {}
      json[:population_criteria].each do |key, population_criteria|
        population_criterias.merge! HQMF::PopulationCriteria.from_json(key.to_s, population_criteria).to_json
      end

      data_criterias = {}
      json[:data_criteria].each do |key, data_criteria|
        data_criterias.merge! HQMF::DataCriteria.from_json(key.to_s, data_criteria).to_json
      end

      measure_period = HQMF::Range.from_json(json[:measure_period]) if json[:measure_period]
      HQMF::Document.new(title, description, population_criterias, data_criterias, measure_period)
    end
    
    def to_json
      json = build_hash(self, [:title, :description])

      json[:population_criteria] = {}
      @population_criteria.each do |population|
        json[:population_criteria].merge! population.to_json
      end

      json[:data_criteria] = {}
      @data_criteria.each do |data|
        json[:data_criteria].merge! data.to_json
      end
      
      json[:measure_period] = @measure_period.to_json

      json
    end
    
    
    # Get all the population criteria defined by the measure
    # @return [Array] an array of HQMF::PopulationCriteria
    def all_population_criteria
      @population_criteria
    end
    
    # Get a specific population criteria by id.
    # @param [String] id the population identifier
    # @return [HQMF::PopulationCriteria] the matching criteria, raises an Exception if not found
    def population_criteria(id)
      find(@population_criteria, :id, id)
    end
    
    # Get all the data criteria defined by the measure
    # @return [Array] an array of HQMF::DataCriteria describing the data elements used by the measure
    def all_data_criteria
      @data_criteria
    end
    
    # Get a specific data criteria by id.
    # @param [String] id the data criteria identifier
    # @return [HQMF::DataCriteria] the matching data criteria, raises an Exception if not found
    def data_criteria(id)
      find(@data_criteria, :id, id)
    end
    
    private
    
    def find(collection, attribute, value)
      collection.find {|e| e.send(attribute)==value}
    end
  end
end