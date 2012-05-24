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
        target = restriction.target
        if (restriction.multi_target?)
          found = false
          # restrictions with restrictions can have a target that is modified by the child restrcitons
          restriction.preconditions.each do |precondition|
            if precondition.reference.id.start_with? target
              found = true
              target = precondition.reference.id
            end
          end
          unless found
            Kernel.warn "multiple targets... need to check this" if restriction.multi_target?
          end
        end
        temporal_reference = HQMF::TemporalReference.new(type, HQMF::Reference.new(target),value)
      elsif (restriction.multi_target?)
        children_criteria = extract_data_criteria(restriction.preconditions, data_criteria_converter)
        if (children_criteria.length == 1)
          target = children_criteria[0].id
          temporal_reference = HQMF::TemporalReference.new(type, HQMF::Reference.new(target),value)
        else
          parent_id = precondition.reference.id
          group_criteria = data_criteria_converter.create_group_data_criteria(children_criteria, "#{type}_CHILDREN", value, parent_id, @@ids.next, "temporal", "temporal")
          temporal_reference = HQMF::TemporalReference.new(type, HQMF::Reference.new(group_criteria.id), value)
        end
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
          if (precondition.reference.id == HQMF::Document::MEASURE_PERIOD_ID)
            flattened << data_criteria_converter.measure_period_criteria
          else
            flattened << data_criteria_converter.v2_data_criteria_by_id[precondition.reference.id]
          end
        else
          flattened.concat(extract_data_criteria(precondition.preconditions,data_criteria_converter))
        end
      end
      flattened
    end
    
    
    
    def self.apply_summary(data_criteria, precondition, restriction, data_criteria_converter)

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
        precondition.reference = HQMF::Reference.new(data_criteria.id)
      elsif (restriction.single_target?)
        subset_operator = HQMF::SubsetOperator.new(type, value)
        data_criteria.subset_operators ||= []
        data_criteria.subset_operators << subset_operator
      end
      
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
