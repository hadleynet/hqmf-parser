module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class OperatorConverter
    
    def self.apply_temporal(data_criteria, precondition, restriction, data_criteria_converter)
      data_criteria.temporal_references ||= []
      value = restriction.operator.value
      type = restriction.operator.type
      temporal_reference = nil
      if (restriction.single_target?)
        # multiple targets appears to be the result of restrictions with restrictions
        Kernel.warn "multiple targets... need to check this" if restriction.multi_target?
        temporal_reference = HQMF::TemporalReference.new(type, HQMF::Reference.new(restriction.target),value)
      elsif (restriction.multi_target?)
        children_criteria = extract_data_criteria(restriction.preconditions, data_criteria_converter)
        parent_id = precondition.reference.id
        group_criteria = data_criteria_converter.create_group_data_criteria(children_criteria, "#{type}_CHILDREN", value, parent_id, @@ids.next, "temporal", "temporal")
        temporal_reference = HQMF::TemporalReference.new(type, HQMF::Reference.new(group_criteria.id), value)
      else
        raise "no target for temporal restriction"
      end
      restriction.converted=true
      data_criteria.temporal_references << temporal_reference
    end
    
    def self.extract_data_criteria(preconditions, data_criteria_converter)
      flattened = []
      preconditions.each do |precondition|
        if (precondition.comparison?) 
          flattened << data_criteria_converter.v2_data_criteria_by_id[precondition.reference.id]
        else
          flattened.concat(extract_data_criteria(precondition.preconditions,data_criteria_converter))
        end
      end
      flattened
    end
    
    
    
    def self.apply_summary(precondition, restriction, data_criteria_converter)

      value = restriction.operator.value
      type = restriction.operator.type
      subset_operator = HQMF::SubsetOperator.new(type, value)

      if (restriction.multi_target?)
        children_criteria = extract_data_criteria(restriction.preconditions, data_criteria_converter)
        
        data_criteria = nil
        if (children_criteria.length == 1)
          data_criteria = children_criteria[0]
          data_criteria.subset_operators ||= []
          data_criteria.subset_operators << subset_operator
        else
          parent_id = "GROUP"
          data_criteria = data_criteria_converter.create_group_data_criteria(children_criteria, type, value, parent_id, @@ids.next, "summary", "summary")
          data_criteria.subset_operators ||= []
          data_criteria.subset_operators << subset_operator
        end
      else
        raise "no target for summary operator"
      end
      
      precondition.reference = HQMF::Reference.new(data_criteria.id)
      restriction.converted=true
    end
    
    # Simple class to issue monotonically increasing integer identifiers
    class Counter
      def initialize
        @count = 0
      end

      def next
        @count+=1
      end
    end
    @@ids = Counter.new

    
  end  
end
