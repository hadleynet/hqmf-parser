module HQMF
  # Class representing an HQMF document
  class Document
    
    MEASURE_PERIOD_ID = "MeasurePeriod"

    include HQMF::Conversion::Utilities

    attr_reader :id, :title, :description, :measure_period, :attributes, :populations
  
    # Create a new HQMF::Document which can be converted to JavaScript
    # @param [String] id
    # @param [String] title
    # @param [String] description
    # @param [Array#PopulationCritera] population_criteria 
    # @param [Array#DataCriteria] data_criteria
    # @param [Array#DataCriteria] source_data_criteria
    # @param [Array#Attribute] attributes
    # @param [Array#Hash] populations
    # @param [Range] measure_period
    def initialize(id, title, description, population_criteria, data_criteria, source_data_criteria, attributes, measure_period, populations=nil)
      @id = id
      @title = title
      @description = description
      @population_criteria = population_criteria
      @data_criteria = data_criteria
      @source_data_criteria = source_data_criteria
      @attributes = attributes
      @populations = populations || [{'IPP'=>'IPP', 'DENOM'=>'DENOM', 'NUMER'=>'NUMER', 'EXCL'=>'EXCL', 'DENEXCEP'=>'DENEXCEP'}]
      @measure_period = measure_period
    end
    
    # Create a new HQMF::Document from a JSON hash keyed with symbols
    def self.from_json(json)
      id = json["id"]
      title = json["title"]
      description = json["description"]
      
      population_criterias = []
      json["population_criteria"].each do |key, population_criteria|
        population_criterias << HQMF::PopulationCriteria.from_json(key.to_s, population_criteria)
      end if json['population_criteria']

      data_criterias = []
      json["data_criteria"].each do |key, data_criteria|
        data_criterias << HQMF::DataCriteria.from_json(key.to_s, data_criteria)
      end

      source_data_criterias = []
      json["source_data_criteria"].each do |key, data_criteria|
        source_data_criterias << HQMF::DataCriteria.from_json(key.to_s, data_criteria)
      end
      
      populations = json["populations"] if json["populations"]

      attributes = json["attributes"].map {|attribute| HQMF::Attribute.from_json(attribute)} if json["attributes"]

      measure_period = HQMF::Range.from_json(json["measure_period"]) if json["measure_period"]
      HQMF::Document.new(id, title, description, population_criterias, data_criterias, source_data_criterias, attributes, measure_period,populations)
    end
    
    def to_json
      json = build_hash(self, [:id, :title, :description])

      json[:population_criteria] = {}
      @population_criteria.each do |population|
        json[:population_criteria].merge! population.to_json
      end

      json[:data_criteria] = {}
      @data_criteria.each do |data|
        json[:data_criteria].merge! data.to_json
      end

      json[:source_data_criteria] = {}
      @source_data_criteria.each do |data|
        json[:source_data_criteria].merge! data.to_json
      end
      
      x = nil
      json[:attributes] = x if x = json_array(@attributes)
      
      json[:populations] = @populations
      
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