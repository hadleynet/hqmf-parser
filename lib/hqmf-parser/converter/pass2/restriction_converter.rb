module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class RestrictionConverter
   
    def self.applyRestrictionsToDataCriteria(precondition, data_criteria, restrictions,data_criteria_converter)
      
      return unless restrictions
      
      restrictions.each do |restriction|
        
        restricted_by = data_criteria_converter.v1_data_criteria_by_id[restriction[:target_id]] if restriction[:target_id]
        
        case restriction[:type]
        when 'REFR'
          if restriction[:field].downcase == 'status'
            data_criteria.status = restriction[:value].downcase
          else
            Kernel.warn "Cannot convert the field of REFR: #{restriction[:field]}"
          end
        when 'RSON'
          Kernel.warn "Ignoring RSON restriction type"
        else
        end
        
        applyRestrictionsToDataCriteria(precondition, data_criteria, restriction[:restrictions],data_criteria_converter) if restriction[:restrictions]
        
      end
      
    end
    
   
  end  
end
