module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PopulationCriteriaConverter
    
    attr_reader :population_criteria
    
    def initialize(doc, data_criteria_converter)
      @doc = doc
      @data_criteria_converter = data_criteria_converter
      @population_criteria = []
      parse()
    end
    
    private 

    def parse()
      @doc[:logic].each do |key,criteria|
        @population_criteria << convert(key.to_s, criteria)
      end
      population_criteria
    end
   
    def convert(key, population_criteria)
      
      # @param [String] id
      # @param [Array#Precondition] preconditions 
     
      id = key
      preconditions = HQMF::PreconditionConverter.parse_preconditions(population_criteria,@data_criteria_converter)      

      HQMF::PopulationCriteria.new(id, preconditions)
     
    end
   
  end  
end
