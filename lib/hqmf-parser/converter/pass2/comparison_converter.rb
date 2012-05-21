module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class ComparisonConverter
    
    def initialize(data_criteria_converter)
      @data_criteria_converter = data_criteria_converter
    end
   
   def convert_comparisons(population_criteria)
     population_criteria.each do |population|
       walk_up_tree(population.preconditions)
     end
   end
   
   def walk_up_tree(preconditions)
     preconditions.each do |precondition|
       if (has_child_comparison(precondition))
         walk_up_tree(precondition.preconditions)
       end
       if (precondition.comparison?)
         new_data_criteria = nil
         if precondition.reference
           data_criteria = @data_criteria_converter.v2_data_criteria_by_id[precondition.reference.id] 
           new_data_criteria = @data_criteria_converter.duplicate_data_criteria(data_criteria, 'precondition', precondition.id)
           precondition.reference.id = new_data_criteria.id
         end
         if precondition.has_preconditions?
           precondition.restrictions.each do |restriction|
             if (restriction.operator.temporal?)
               HQMF::OperatorConverter.apply_temporal(new_data_criteria, precondition, restriction, @data_criteria_converter)
             elsif(restriction.operator.summary?)
               HQMF::OperatorConverter.apply_summary(precondition, restriction, @data_criteria_converter)
             else
               Kernel.warn "Operator is unknown: #{restriction.operator.type}"
             end
           end
           precondition.delete_converted_restrictions!
         end
       end
     end
   end
   
   def has_child_comparison(node)
     value = false
     node.preconditions.each do |precondition|
       if (precondition.comparison?)
         value ||= true
       elsif precondition.has_preconditions?
         value ||= has_child_comparison(precondition)
       end
     end
     value
   end

  end  
end