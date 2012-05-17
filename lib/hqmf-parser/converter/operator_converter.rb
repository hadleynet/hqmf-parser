module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class OperatorConverter
   
    def self.applyOperatorToDataCriteria(expression, preconditions, data_criteria_converter)

      children = flatten_preconditions(preconditions)
      
      child_ids = children.map(&:reference).map(&:id)
      clean_ids = child_ids.map {|key| key.gsub /_precondition_\d+/, ''}
      
      id = "#{expression[:type]}_#{@@ids.next}"
      children_criteria = child_ids
      subset_value = parse_value(expression[:value]) if expression[:value]
      value_string = (subset_value.stringify if subset_value) || ""
      title = "#{expression[:type]}#{value_string}"
      description = "#{expression[:type]}(#{clean_ids.join(',')})#{value_string}"
      standard_category = "operator"
      qds_data_type = "operator"
      subset_code = expression[:type]
      code_list_id = nil
      property = nil
      type = nil
      status = nil
      value = nil
      effective_time = nil
      inline_code_list = nil
      negation = nil
      temporal_reference = nil
      
      data_criteria = HQMF::DataCriteria.new(id, title, description, standard_category, qds_data_type, subset_code, subset_value,
                                             code_list_id, children_criteria, property,type, status, value, effective_time, inline_code_list,
                                             negation,temporal_reference)

      data_criteria_converter.v2_data_criteria << data_criteria
      
      HQMF::Reference.new(id)
    end
    
    def self.parse_value(value)
      if (value[:value])
        # values should be inclusive since we will be asking if it equals the value, ranther than being part of a range
        HQMF::Value.from_json(JSON.parse(value.to_json).merge({"inclusive?"=>true}))
      elsif (value[:high] or value[:low])
        HQMF::Range.from_json(JSON.parse(value.to_json))
      end
    end
    
    def self.flatten_preconditions(preconditions)
      flattened = []
      preconditions.each do |precondition|
        if (precondition.reference and !precondition.preconditions.empty?)
          binding.pry
          raise "don't know how to handle a condition with a reference that has preconditions" if (precondition.reference and !precondition.preconditions.empty?)
        end
        if (precondition.reference) 
          flattened << precondition
        else
          flattened.concat(flatten_preconditions(precondition.preconditions))
        end
      end
      flattened
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
