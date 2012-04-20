module HQMF
  # Represents a data criteria specification
  class DataCriteria

    include HQMF::JSON::Utilities

    attr_reader :id,:title,:section,:subset_code,:code_list_id, :property, :type, :status, :inline_code_list, :standard_category, :qds_data_type, :negation
    attr_accessor :value, :effective_time
  
    # Create a new data criteria instance
    # @param [String] id
    # @param [String] title
    # @param [String] standard_category
    # @param [String] qds_data_type
    # @param [String] subset_code
    # @param [String] code_list_id
    # @param [String] property
    # @param [String] type
    # @param [String] status
    # @param [Value|Range|Coded] value
    # @param [Range] effective_time
    # @param [Hash<String,String>] inline_code_list
    # @param [boolean] negation
    def initialize(id, title, standard_category, qds_data_type, subset_code, 
        code_list_id, property,type, status, value, effective_time, inline_code_list,
        negation)
      @id = id
      @title = title
      @standard_category = standard_category
      @qds_data_type = qds_data_type
      @subset_code = subset_code
      @code_list_id = code_list_id
      @property = property
      @type = type
      @status = status
      @value = value
      @effective_time = effective_time
      @inline_code_list = inline_code_list
      @negation = negation
    end
    
    # Create a new data criteria instance from a JSON hash keyed with symbols
    def self.from_json(id, json)
      title = json[:title] if json[:title]
      standard_category = json[:standard_category] if json[:standard_category]
      qds_data_type = json[:qds_data_type] if json[:standard_category]
      subset_code = json[:subset_code] if json[:subset_code]
      code_list_id = json[:code_list_id] if json[:code_list_id]
      property = json[:property].to_sym if json[:property]
      type = json[:type].to_sym if json[:type]
      status = json[:status] if json[:status]
      negation = json[:negation] || false

      value = convert_value(json[:value]) if json[:value]
      effective_time = HQMF::Range.from_json(json[:effective_time]) if json[:effective_time]
      inline_code_list = json[:inline_code_list].inject({}){|memo,(k,v)| memo[k.to_s] = v; memo} if json[:inline_code_list]
      
      HQMF::DataCriteria.new(id, title, standard_category, qds_data_type, subset_code, 
        code_list_id, property, type, status, value, effective_time, inline_code_list,
        negation)
      
    end
    
    def to_json
      json = build_hash(self, [:title,:standard_category,:qds_data_type,:subset_code,:code_list_id, :property, :type, :status, :negation])
      json[:value] = self.value.to_json if self.value
      json[:effective_time] = self.effective_time.to_json if self.effective_time
      json[:inline_code_list] = self.inline_code_list if self.inline_code_list
      {self.id.to_s.to_sym => json}
    end
    
    
    private 
    
    def self.convert_value(json)
      value = nil
      type = json[:type]
      case type
        when 'TS'
          value = HQMF::Value.from_json(json)
        when 'IVL_PQ'
          value = HQMF::Range.from_json(json)
        when 'CD'
          value = HQMF::Coded.from_json(json)
        else
          raise "Unknown value type [#{value_type}]"
        end
      value
    end
    

  end
  
end