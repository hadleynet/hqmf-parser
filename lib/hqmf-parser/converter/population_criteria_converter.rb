module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PopulationCriteriaConverter
   
    def self.convert(key, population_criteria,data_criteria_by_id)
      
      # @param [String] id
      # @param [Array#Precondition] preconditions 
     
      id = key
      preconditions = parse_preconditions(population_criteria,data_criteria_by_id)

      HQMF::PopulationCriteria.new(id, preconditions)
     
    end
    
    private
    
    def self.parse_preconditions(source,data_criteria_by_id)
      HQMF::PreconditionConverter.parse_preconditions(source,data_criteria_by_id)
    end
   
  end  
end
