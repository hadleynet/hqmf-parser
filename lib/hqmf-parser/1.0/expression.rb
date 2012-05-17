module HQMF1
  
  class Expression
  
    include HQMF1::Utilities
    
    attr_reader :text, :value, :type
  
    def initialize(entry)
      @entry = entry
      @text = @entry.xpath('./*/cda:derivationExpr').text.strip
      type = attr_val('./*/cda:value/@xsi:type')
      case type
      when 'IVL_PQ'
        @value = Range.new(@entry.xpath('./*/cda:value'))
      when 'PQ'
        @value = Value.new(@entry.xpath('./*/cda:value'))
      else
        raise "Unknown expression value type #{type}"
      end
      @type = match_type
    end
    
    def match_type
      case @text
        when /^COUNT(.*)$/
          "COUNT"
        else
          "UNKNOWN"
      end
    end
    
    def to_json
      
      json = build_hash(self, [:text,:type])
      json[:value] = self.value.to_json if self.value
      json
      
    end
    
  end
  
  
end