module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PreconditionConverter
   
    def self.parse_preconditions(source,data_criteria_by_id)
      preconditions = []
      source.each do |precondition|
        preconditions << HQMF::PreconditionConverter.parse_precondition(precondition,data_criteria_by_id)
      end
      preconditions
    end
   
    # converts a precondtion to a hqmf model
    def self.parse_precondition(precondition,data_criteria_by_id)
      
      # grab child preconditions, and parse recursively
      preconditions = parse_and_merge_preconditions(precondition[:preconditions],data_criteria_by_id) if precondition[:preconditions] || []
      
      # TODO: we are currently pulling preconditions from restrictions... these should be moved to temporal references on the data criteria
      Kernel.warn('pulled preconditions from restrictions... these should be temporal references on the data criteria')
      preconditions_from_restrictions = HQMF::PreconditionExtractor.extract_preconditions_from_restrictions(precondition[:restrictions], data_criteria_by_id)
      preconditions.concat(preconditions_from_restrictions)
      
      conjunction_code = convert_logical_conjunction(precondition[:conjunction])
      negation = precondition[:negation]
      
      Kernel.warn ("need to push down values, restrictions, effective_date to data criteria")
      # reference is for data preconditions
      reference = nil
      
      if (precondition[:comparison])
        preconditions ||= []
        comparison_precondition = HQMF::PreconditionExtractor.convert_comparison_to_precondition(precondition[:comparison],data_criteria_by_id)
        preconditions << comparison_precondition
      end
      
      HQMF::Precondition.new(preconditions,reference,conjunction_code, negation)
      
    end
    
    private 
    
    def self.parse_and_merge_preconditions(source, data_criteria_by_id)
      return [] unless source and source.size > 0
      preconditions_by_conjunction = {}
      source.each do |precondition|
        parsed = HQMF::PreconditionConverter.parse_precondition(precondition,data_criteria_by_id)
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
        negation = false
        sub_conditions.each {|precondition| negation ||= precondition.negation}
        joined << HQMF::Precondition.new(sub_conditions,nil,conjunction_code, negation)
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
