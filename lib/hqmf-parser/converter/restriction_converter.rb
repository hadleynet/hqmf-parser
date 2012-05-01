module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class RestrictionConverter
   
    def self.applyRestrictionsToDataCriteria(data_criteria, restrictions,data_criteria_by_id)
      
      restrictions.each do |restriction|
        restricted_by = data_criteria_by_id[restriction[:target_id]] if restriction[:target_id]
        case restriction[:type]
        when 'DURING'
          data_criteria.effective_time = restricted_by.value
        when 'SBS'
          data_criteria.effective_time ||= HQMF::EffectiveTime.new(nil,nil,nil)
          data_criteria.effective_time.high = restricted_by.value.low
          if (restriction[:range])
            low_restriction = restriction[:range][:low] 
            high_restriction = restriction[:range][:high] 
            data_criteria.value = HQMF::Range.new('IVL_PQ',nil,nil,nil)
            data_criteria.value.low = HQMF::Value.new('PQ',low_restriction[:unit],low_restriction[:value],low_restriction[:inclusive?],low_restriction[:derived?],low_restriction[:expression]) if low_restriction
            data_criteria.value.high = HQMF::Value.new('PQ',high_restriction[:unit],high_restriction[:value],high_restriction[:inclusive?],high_restriction[:derived?],high_restriction[:expression]) if high_restriction
          end
        when 'EAS'
          temporal_reference = convert_preconditions_to_temporal_reference(restriction[:type],restriction[:preconditions]) if restriction[:preconditions]
          data_criteria.temporal_references ||= []
          data_criteria.temporal_references << temporal_reference
        when 'REFR'
          if restriction[:field].downcase == 'status'
            data_criteria.status = restriction[:value].downcase
          else
            raise "Cannot convert the field of REFR: #{restriction[:field]}"
          end
        when 'DRIV'
          Kernel.warn "Ignoring DRIV restriction type (I think it's used for restrictions of preconditions)"
        else
          raise "The restriction type is not yet supported: #{restriction[:type]}"
        end
        
        applyRestrictionsToDataCriteria(data_criteria, restriction[:restrictions],data_criteria_by_id) if restriction[:restrictions]
        
      end
      
    end
    
    def self.convert_preconditions_to_temporal_reference(type, preconditions)
      
      Kernel.warn "Temporal References do no handle ranges"
      Kernel.warn "Temporal References do no handle hierarchies"
      range = nil
      
      by_conjunction = {}
      preconditions.each do |precondition|
        by_conjunction[precondition[:conjunction]] ||= []
        by_conjunction[precondition[:conjunction]] << precondition[:comparison][:data_criteria_id]
      end
      
      references = []
      by_conjunction.keys.each do |conjunction|
        references << LogicalReference.new(conjunction, by_conjunction[conjunction])
      end
      
      TemporalReference.new(type,references,range)
      
    end
   
  end  
end
