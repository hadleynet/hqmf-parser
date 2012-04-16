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
          data_criteria.effective_time ||= JSON::EffectiveTime.new(nil,nil,nil)
          data_criteria.effective_time.high = restricted_by.value.low
          if (restriction[:range])
            low_restriction = restriction[:range][:low] 
            high_restriction = restriction[:range][:low] 
            data_criteria.value = JSON::Range.new('IVL_PQ',nil,nil,nil)
            data_criteria.value.low = JSON::Value.new('PQ',low_restriction[:unit],low_restriction[:value],low_restriction[:inclusive?],low_restriction[:derived?],low_restriction[:expression]) if low_restriction
            data_criteria.value.high = JSON::Value.new('PQ',high_restriction[:unit],high_restriction[:value],high_restriction[:inclusive?],high_restriction[:derived?],high_restriction[:expression]) if high_restriction
          end
        else
          raise "The restriction type is not yet supported: #{restriction[:type]}"
        end
        
      end
      
    end
   
  end  
end
