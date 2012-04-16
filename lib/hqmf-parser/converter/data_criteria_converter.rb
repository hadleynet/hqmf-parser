module HQMF
  # Class representing an HQMF document
  class DataCriteriaConverter

    def self.convert(key, criteria)
 
      # @param [String] id
      # @param [String] title
      # @param [String] section
      # @param [String] subset_code
      # @param [String] code_list_id
      # @param [String] property
      # @param [String] type
      # @param [String] status
      # @param [Value|Range|Coded] value
      # @param [Range] effective_time
      # @param [Hash<String,String>] inline_code_list

      id = convert_key(key)
      title = criteria[:title]
      type = criteria[:type]
      section = convert_data_criteria_section(type)
      code_list_id = criteria[:code_list_id]
      property = convert_data_criteria_property(criteria[:property]) if criteria[:property]
      # TODO: NEED TO FINALIZE THESE
      Kernel.warn "We still need to map status, value, effective_time, inline_code_list, and subset_code"
      status = nil
      value = nil
      effective_time = nil
      inline_code_list = nil
      subset_code = nil

      JSON::DataCriteria.new(id, title,section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
 
    end

    private 

    def self.convert_data_criteria_section(type)
      case type
        when 'encounter'
          'encounters'
        when 'procedure'
          'procedures'
        when 'medication'
          'medications'
        when 'characteristic'
          'characteristic'
        else
          raise "unsupported data criteria type conversion: #{type}"
      end
    end

    def self.convert_data_criteria_property(property)
      case property
        when 'birthtime'
          'age'
        else
          raise "unsupported data criteria property conversion: #{property}"
      end
    end

    def self.convert_key(key)
      key.to_s.downcase.gsub('_', ' ').split(' ').map {|w| w.capitalize }.join('')
    end
  end
end
