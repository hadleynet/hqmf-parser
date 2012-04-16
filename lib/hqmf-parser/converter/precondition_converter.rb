module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PreconditionConverter
   
    def self.convert_logical(precondition,data_criteria_by_id)
      
      # @param [Array#Precondition] preconditions 
      # @param [Reference] reference
      # @param [String] conjunction_code
      
      # TODO: need to create preconditions for comparisons that attach to data criteria
      preconditions = parse_preconditions(precondition[:preconditions],data_criteria_by_id) if precondition[:preconditions]
      conjunction_code = convert_logical_conjunction(precondition[:conjunction])
      Kernel.warn ("need to push down values, restrictions, effective_date to data criteria")
      # reference is for data preconditions
      reference = nil
      
      if (precondition[:comparison])
        preconditions ||= []
        preconditions << convert_comparison_to_precondition(precondition[:comparison],data_criteria_by_id)
      end
      
      JSON::Precondition.new(preconditions,reference,conjunction_code)
      
    end

    def self.convert_comparison_to_precondition(comparison, data_criteria_by_id)
      
      data_criteria = data_criteria_by_id[comparison[:data_criteria_id]]
      
      reference = JSON::Reference.new(data_criteria.id)
      conjunction_code = "#{data_criteria.type}Reference"
      preconditions = nil
      
      Kernel.warn('restrictions not pushed down to comparisons are not picked up')
      HQMF::RestrictionConverter.applyRestrictionsToDataCriteria(data_criteria, comparison[:restrictions],data_criteria_by_id)
      
      JSON::Precondition.new(preconditions,reference,conjunction_code)
    end
   
    private 
    
    def self.parse_preconditions(source, data_criteria_by_id)
      preconditions_by_conjunction = {}
      source.each do |precondition|
        parsed = HQMF::PreconditionConverter.convert_logical(precondition,data_criteria_by_id)
        preconditions_by_conjunction[parsed.conjunction_code] ||= []
        preconditions_by_conjunction[parsed.conjunction_code]  << parsed
      end
      
      merge_precondtion_conjunction_groups(preconditions_by_conjunction)
    end
    
    def self.merge_precondtion_conjunction_groups(preconditions_by_conjunction)
      joined = []
      preconditions_by_conjunction.each do |conjunction_code, preconditions|
        sub_conditions = []
        preconditions.each do |precondition|
          sub_conditions.concat precondition.preconditions if precondition.preconditions
        end
        joined << JSON::Precondition.new(sub_conditions,nil,conjunction_code)
      end
      joined
    end
    
    def self.convert_logical_conjunction(code)
      case code
        when 'OR'
          'atLeastOneTrue'
        when 'AND'
          'allTrue'
        else
          raise "unsupported logical conjunction code conversion: #{code}"
      end
      
    end
    
   
  end  
end
