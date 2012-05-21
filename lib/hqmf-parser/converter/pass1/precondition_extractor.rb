module HQMF
  
  # preconditions can be in several places.
  #
  # precondition -> preconditions
  # restriction -> preconditions
  #
  # also, restrictions can be on the following, which can then have preconditions
  #   restrictions
  #   comparisons
  #   preconditions
  #
  class PreconditionExtractor
   
   
    # TODO: This should probably NOT be done.  We are pulling restriction preconditions directly into the tree
    # instead, we should push these down to the data criteria under temporal restrictions, or however else they are handled
    def self.extract_preconditions_from_restrictions(restrictions,data_criteria_converter)
      return [] unless restrictions
      preconditions = []
      restrictions.each do |restriction|
        preconditions.concat(extract_preconditions_from_restriction(restriction,data_criteria_converter))
      end
      preconditions      
    end
    
    # get all the preconditions for a restriction (this should eventually get pushed down to data criteria)
    # we need to iterate down 
    #   restriction.preconditions
    #   restriction.comparison
    #   restriction.restriction
    def self.extract_preconditions_from_restriction(restriction,data_criteria_converter)

      target_id = data_criteria_converter.v1_data_criteria_by_id[restriction[:target_id]].id if restriction[:target_id]
      type = restriction[:type]
      if (restriction[:negation]) 
        inverted = HQMF::TemporalReference::INVERSION[type] 
        if (inverted)
          type = inverted
        else
          Kernel.warn "don't know how to invert #{type}"
        end
      end
      
      value = nil
      if (restriction[:range])
        value = HQMF::Range.from_json(JSON.parse(restriction[:range].to_json)) if (restriction[:range])
      elsif(restriction[:value])
        value = restriction[:value]
      end
      field = restriction[:field]
      operator = HQMF::Converter::SimpleOperator.new(HQMF::Converter::SimpleOperator.find_category(type), type, value, field)
      container = HQMF::Converter::SimpleRestriction.new(operator, target_id)
      
      # get the precondtions off of the restriction
      container.preconditions = HQMF::PreconditionConverter.parse_and_merge_preconditions(restriction[:preconditions],data_criteria_converter) if restriction[:preconditions]
      
      if restriction[:comparison]
        container.preconditions ||= []
        # check comparison and convert it to a precondition
        comparison = convert_comparison_to_precondition(restriction[:comparison], data_criteria_converter)
        container.preconditions << comparison
      end
      
      # check restrictions
      restrictions = extract_preconditions_from_restrictions(restriction[:restrictions], data_criteria_converter) if restriction[:restrictions]
      
      HQMF::PreconditionConverter.apply_restrictions_to_comparisons(container.preconditions, restrictions) unless restrictions.nil? or restrictions.empty?
      
      [container]
    end


    # we want the comparisons to be converted to the leaf preconditions
    def self.convert_comparison_to_precondition(comparison, data_criteria_converter)

      data_criteria = data_criteria_converter.v1_data_criteria_by_id[comparison[:data_criteria_id]]
      reference = HQMF::Reference.new(data_criteria.id)
      conjunction_code = "#{data_criteria.type}Reference"

      preconditions = []
      if comparison[:restrictions]
         # check for preconditions on restrictions
         preconditions = extract_preconditions_from_restrictions(comparison[:restrictions], data_criteria_converter) 
      end
      
      precondition = HQMF::Converter::SimplePrecondition.new(nil,preconditions,reference,conjunction_code, false)
      precondition.klass = HQMF::Converter::SimplePrecondition::COMPARISON
      
      if (comparison[:subset])
        # create a restriction for a comparison subset... this is for things like first, second, etc.
        type = comparison[:subset]
        operator = HQMF::Converter::SimpleOperator.new(HQMF::Converter::SimpleOperator.find_category(type), type, nil)
        restriction = HQMF::Converter::SimpleRestriction.new(operator, reference.id, nil)
        precondition.preconditions ||= []
        precondition.preconditions << restriction
      end

      precondition
    end
    
    # flatten a tree of preconditions into an array... if we are doing something like a count, we just want the flat list
    def self.flatten_v2_preconditions(preconditions)
      flattened = []
      preconditions.each do |precondition|
        if (precondition.reference and precondition.has_preconditions?)
          raise "don't know how to handle a condition with a reference that has preconditions" if (precondition.reference and precondition.has_preconditions?)
        end
        if (precondition.reference) 
          flattened << precondition
        else
          flattened.concat(flatten_v2_preconditions(precondition.preconditions))
        end
      end
      flattened
    end
    
  end  
end
