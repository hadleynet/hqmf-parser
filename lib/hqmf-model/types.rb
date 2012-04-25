module HQMF
  # Represents a bound within a HQMF pauseQuantity, has a value, a unit and an
  # inclusive/exclusive indicator
  class Value
    include HQMF::JSON::Utilities
    attr_reader :type,:unit,:value,:expression
    
    # Create a new HQMF::Value
    # @param [String] type
    # @param [String] unit
    # @param [String] value
    # @param [String] inclusive
    # @param [String] derived
    # @param [String] expression
    def initialize(type,unit,value,inclusive,derived,expression)
      @type = type
      @unit = unit
      @value = value
      @inclusive = inclusive
      @derived = derived
      @expression = expression
    end
    
    def self.from_json(json)
      type = json["type"] if json["type"]
      unit = json["unit"] if json["unit"]
      value = json["value"] if json["value"]
      inclusive = json["inclusive?"] if json["inclusive?"]
      derived = json["derived?"] if json["derived?"]
      expression = json["expression"] if json["expression"]
      
      HQMF::Value.new(type,unit,value,inclusive,derived,expression)
    end
    
    
    def inclusive?
      @inclusive
    end

    def derived?
      @derived
    end
    
    def to_json
      build_hash(self, [:type,:unit,:value,:inclusive?,:derived?,:expression])
    end
    
  end
  
  # Represents a HQMF physical quantity which can have low and high bounds
  class Range
    include HQMF::JSON::Utilities
    attr_reader :type
    attr_accessor :low, :high, :width
    
    # Create a new HQMF::Value
    # @param [String] type
    # @param [Value] low
    # @param [Value] high
    # @param [Value] width
    def initialize(type,low,high,width)
      @type = type
      @low = low
      @high = high
      @width = width
    end
    
    def self.from_json(json)
      type = json["type"] if json["type"]
      low = HQMF::Value.from_json(json["low"]) if json["low"]
      high = HQMF::Value.from_json(json["high"]) if json["high"]
      width = HQMF::Value.from_json(json["width"]) if json["width"]
      
      HQMF::Range.new(type,low,high,width)
    end
    
    def to_json
      json = build_hash(self, [:type])
      json[:low] = self.low.to_json if self.low
      json[:high] = self.high.to_json if self.high
      json[:width] = self.width.to_json if self.width
      json
    end
    
  end
  
  # Represents a HQMF effective time which is a specialization of a interval
  class EffectiveTime < Range
    def initialize(low,high,width)
      super('LVL_TS', low, high, width)
    end
    
    def type
      'IVL_TS'
    end
  end
  
  # Represents a HQMF CD value which has a code and codeSystem
  class Coded
    include HQMF::JSON::Utilities
    attr_reader :type, :system, :code
    
    # Create a new HQMF::Coded
    # @param [String] type
    # @param [String] system
    # @param [String] code
    def initialize(type,system,code)
      @type = type
      @system = system
      @code = code
    end
    
    def self.from_json(json)
      type = json["type"] if json["type"]
      system = json["system"] if json["system"]
      code = json["code"] if json["code"]
      
      HQMF::Coded.new(type,system,code)
    end
    
    def to_json
      build_hash(self, [:type,:system,:code])
    end
    
    def value
      code
    end

    def derived?
      false
    end

    def unit
      nil
    end
    
  end
  
  # Represents a HQMF reference from a precondition to a data criteria
  class Reference
    include HQMF::JSON::Utilities
    attr_reader :id
    
    # Create a new HQMF::Reference
    # @param [String] id
    def initialize(id)
      @id = id
    end
    
  end
  
end