module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PreconditionConverter
    
    def self.parse_preconditions(source,data_criteria_converter)
      preconditions = []
      source.each do |precondition|
        preconditions << HQMF::PreconditionConverter.parse_precondition(precondition,data_criteria_converter)
      end
      preconditions
    end
   
    # converts a precondtion to a hqmf model
    def self.parse_precondition(precondition,data_criteria_converter)
      
      # grab child preconditions, and parse recursively
      preconditions = parse_and_merge_preconditions(precondition[:preconditions],data_criteria_converter) if precondition[:preconditions] || []
      
      preconditions_from_restrictions = HQMF::PreconditionExtractor.extract_preconditions_from_restrictions(precondition[:restrictions], data_criteria_converter)
      
      driv_preconditions = []
      preconditions_from_restrictions.delete_if {|element| driv_preconditions << element if element.is_a? HQMF::Converter::SimpleRestriction and element.operator.type == 'DRIV'}
      
      apply_restrictions_to_comparisons(preconditions, preconditions_from_restrictions) unless preconditions_from_restrictions.empty?


      if (precondition[:expression])
        # this is for things like COUNT
        type = precondition[:expression][:type]
        operator = HQMF::Converter::SimpleOperator.new(HQMF::Converter::SimpleOperator.find_category(type), type, HQMF::Converter::SimpleOperator.parse_value(precondition[:expression][:value]))
        children = []
        if driv_preconditions and !driv_preconditions.empty?
          children = driv_preconditions.map(&:preconditions).flatten
        end
        
        reference = nil
        conjunction_code = "operator"
        
        restriction = HQMF::Converter::SimpleRestriction.new(operator, nil, children)
        
        comparison_precondition = HQMF::Converter::SimplePrecondition.new(nil,[restriction],reference,conjunction_code, false)
        comparison_precondition.klass = HQMF::Converter::SimplePrecondition::COMPARISON
        preconditions << comparison_precondition
      end
      
      reference = nil
      
      conjunction_code = convert_logical_conjunction(precondition[:conjunction])
      negation = precondition[:negation]
      
      
      if (precondition[:comparison])
        preconditions ||= []
        comparison_precondition = HQMF::PreconditionExtractor.convert_comparison_to_precondition(precondition[:comparison],data_criteria_converter)
        preconditions << comparison_precondition
      end
      
      HQMF::Converter::SimplePrecondition.new(nil,preconditions,reference,conjunction_code, negation)
      
    end

    def self.get_comparison_preconditions(preconditions)
      comparisons = []
      preconditions.each do |precondition|
        if (precondition.comparison?)
          comparisons << precondition
        elsif(precondition.has_preconditions?)
          comparisons.concat(get_comparison_preconditions(precondition.preconditions))
        else
          raise "precondition with no comparison or children... not valid"
        end
      end
      comparisons
    end

    def self.apply_restrictions_to_comparisons(preconditions, restrictions)
      comparisons = get_comparison_preconditions(preconditions)
      raise "no comparisons to apply restriction to" if comparisons.empty?
      comparisons.each do |comparison|
        comparison.preconditions.concat(restrictions)
      end
    end
    
    private 
    
    
    def self.parse_and_merge_preconditions(source,data_criteria_converter)
      return [] unless source and source.size > 0
      preconditions_by_conjunction = {}
      source.each do |precondition|
        parsed = HQMF::PreconditionConverter.parse_precondition(precondition,data_criteria_converter)
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
        sub_conditions.each {|precondition| negation ||= precondition.negation }
        joined << HQMF::Converter::SimplePrecondition.new(nil,sub_conditions,nil,conjunction_code, negation)
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
