module HQMF
  # Class representing an HQMF document
  class DataCriteriaConverter

    def self.convert(key, criteria)
 
      # @param [String] id
      # @param [String] title
      # @param [String] standard_category
      # @param [String] qds_data_type
      # @param [String] subset_code
      # @param [String] code_list_id
      # @param [String] property
      # @param [String] type
      # @param [String] status
      # @param [boolean] negation
      # @param [Value|Range|Coded] value
      # @param [Range] effective_time
      # @param [Hash<String,String>] inline_code_list

      id = convert_key(key)
      title = criteria[:title]
      type = criteria[:type]
      standard_category = criteria[:standard_category]
      qds_data_type = criteria[:qds_data_type]
      code_list_id = criteria[:code_list_id]
      property = convert_data_criteria_property(criteria[:property]) if criteria[:property]
      status = criteria[:status]
      negation = criteria[:negation]
      # TODO: NEED TO FINALIZE THESE
      Kernel.warn "We still need to map value, effective_time, inline_code_list, and subset_code"
      value = nil
      effective_time = nil
      inline_code_list = nil
      subset_code = nil
      temporal_references = []

      HQMF::DataCriteria.new(id, title, standard_category, qds_data_type, subset_code, 
        code_list_id, property,type, status, value, effective_time, inline_code_list,
        negation, temporal_references)
 
    end

    private 

    def self.convert_data_criteria_property(property)
      case property
        when 'birthtime', :birthtime
          :age
        when 'gender', :gender
          :gender
        when 'unknown', :unknown
          Kernel.warn("data criteria property is unknown")
        else
          raise "unsupported data criteria property conversion: #{property}"
      end
    end

    def self.convert_key(key)
      key.to_s.downcase.gsub('_', ' ').split(' ').map {|w| w.capitalize }.join('')
    end
  end
end
