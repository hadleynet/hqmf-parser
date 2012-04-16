module JSON
  # Represents a data criteria specification
  class DataCriteria

    attr_reader :id,:title,:section,:subset_code,:code_list_id, :property, :type, :status, :inline_code_list
    attr_accessor :value, :effective_time
  
    # Create a new data criteria instance
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
    def initialize(id, title,section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      @id = id
      @title = title
      @section = section
      @subset_code = subset_code
      @code_list_id = code_list_id
      @property = property
      @type = type
      @status = status
      @value = value
      @effective_time = effective_time
      @inline_code_list = inline_code_list
    end
    
    # Create a new data criteria instance from a JSON hash keyed with symbols
    def self.from_json(id, json)
      title = json[:title] if json[:title]
      section = json[:section] if json[:section]
      subset_code = json[:subset_code] if json[:subset_code]
      code_list_id = json[:code_list_id] if json[:code_list_id]
      property = json[:property].to_sym if json[:property]
      type = json[:type].to_sym if json[:type]
      status = json[:status] if json[:status]

      value = convert_value(json[:value]) if json[:value]
      effective_time = JSON::Range.from_json(json[:effective_time]) if json[:effective_time]
      inline_code_list = json[:inline_code_list].inject({}){|memo,(k,v)| memo[k.to_s] = v; memo} if json[:inline_code_list]
      
      JSON::DataCriteria.new(id,title,section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      
    end
    
    def to_json
      json = build_hash(self, [:title,:section,:subset_code,:code_list_id, :property, :type, :status])
      json[:value] = self.value.to_json if self.value
      json[:effective_time] = self.effective_time.to_json if self.effective_time
      json[:inline_code_list] = self.inline_code_list if self.inline_code_list
      {self.id.to_sym => json}
    end
    
    
    private 
    
    def self.convert_value(json)
      value = nil
      type = json[:type]
      case type
        when 'TS'
          value = JSON::Value.from_json(json)
        when 'IVL_PQ'
          value = JSON::Range.from_json(json)
        when 'CD'
          value = JSON::Coded.from_json(json)
        else
          raise "Unknown value type [#{value_type}]"
        end
      value
    end
    

  end
  
end