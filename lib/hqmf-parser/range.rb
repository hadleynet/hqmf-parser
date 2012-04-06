module HQMF
  # Represents a bound within a HQMF pauseQuantity, has a value, a unit and an
  # inclusive/exclusive indicator
  class Value
    include HQMF::Utilities
    
    def initialize(entry)
      @entry = entry
    end
    
    def value
      attr_val('./@value')
    end
    
    def unit
      attr_val('./@unit')
    end
    
    def inclusive?
      case attr_val('./@inclusive')
      when 'true'
        true
      else
        false
      end
    end
    
    def to_json
      json = {
        value: self.value,
        unit: self.unit,
        inclusive?: self.inclusive?
      }
      clean_json(json)
    end
  end
  
  # Represents a HQMF pauseQuantity which can have low and high bounds
  class Range
    include HQMF::Utilities
    attr_reader :low, :high
    
    def initialize(entry)
      @entry = entry
      if @entry
        @low = optional_value('./cda:low')
        @high = optional_value('./cda:high')
      end
    end
   
    def to_json
      json = {
        low: (self.low.to_json if self.low),
        high: (self.high.to_json if self.high)
      }
      clean_json(json)
    end
    
    private
    
    def optional_value(xpath)
      value_def = @entry.at_xpath(xpath)
      if value_def
        Value.new(value_def)
      else
        nil
      end
    end
    
  end
end