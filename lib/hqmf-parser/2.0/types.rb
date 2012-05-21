module HQMF2
  # Represents a bound within a HQMF pauseQuantity, has a value, a unit and an
  # inclusive/exclusive indicator
  class Value
    include HQMF2::Utilities
    
    attr_reader :type, :unit, :value
    
    def initialize(entry, default_type='PQ')
      @entry = entry
      @type = attr_val('./@xsi:type') || default_type
      @unit = attr_val('./@unit')
      @value = attr_val('./@value')
    end
    
    def inclusive?
      case attr_val('./@inclusive')
      when 'true'
        true
      else
        false
      end
    end
    
    def derived?
      case attr_val('./@nullFlavor')
      when 'DER'
        true
      else
        false
      end
    end
    
    def expression
      if !derived?
        nil
      else
        @entry.at_xpath('./cda:expression', HQMF2::Document::NAMESPACES).inner_text
      end
    end
    
    def to_json
      build_hash(self, [:type,:unit,:value,:inclusive?,:derived?,:expression])
    end
  end
  
  # Represents a HQMF physical quantity which can have low and high bounds
  class Range
    include HQMF2::Utilities
    attr_reader :low, :high, :width
    
    def initialize(entry)
      @entry = entry
      if @entry
        @low = optional_value('./cda:low', default_bounds_type)
        @high = optional_value('./cda:high', default_bounds_type)
        @width = optional_value('./cda:width', 'PQ')
      end
    end
    
    def type
      attr_val('./@xsi:type')
    end
    
    def to_json
      json = build_hash(self, [:type])
      json[:low] = self.low.to_json if self.low
      json[:high] = self.high.to_json if self.high
      json[:width] = self.width.to_json if self.width
      json
    end
    
    private
    
    def optional_value(xpath, type)
      value_def = @entry.at_xpath(xpath, HQMF2::Document::NAMESPACES)
      if value_def
        Value.new(value_def, type)
      else
        nil
      end
    end
    
    def default_bounds_type
      case type
      when 'IVL_TS'
        'TS'
      else
        'PQ'
      end
    end
  end
  
  # Represents a HQMF effective time which is a specialization of a interval
  class EffectiveTime < Range
    def initialize(entry)
      super
    end
    
    def type
      'IVL_TS'
    end
  end
  
  # Represents a HQMF CD value which has a code and codeSystem
  class Coded
    include HQMF2::Utilities
    
    def initialize(entry)
      @entry = entry
    end
    
    def type
      attr_val('./@xsi:type')
    end
    
    def system
      attr_val('./@codeSystem')
    end
    
    def code
      attr_val('./@code')
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
    
    def to_json
      build_hash(self, [:type,:system,:code])
    end
  end
  
  class SubsetOperator
    include HQMF2::Utilities

    attr_reader :type, :value

    def initialize(entry)
      @entry = entry
      @type = attr_val('./cda:subsetCode/@code')
      value_def = @entry.at_xpath('./*/cda:repeatNumber', HQMF2::Document::NAMESPACES)
      if value_def
        @value = HQMF2::Range.new(value_def)
      end
    end

    def to_json
      x = nil
      json = build_hash(self, [:type])
      json[:value] = @value.to_json if @value
      json
    end
  end
  
  class TemporalReference
    include HQMF2::Utilities
    
    attr_reader :type, :reference, :offset

    def initialize(entry)
      @entry = entry
      @type = attr_val('./@typeCode')
      @reference = Reference.new(@entry.at_xpath('./*/cda:id', HQMF2::Document::NAMESPACES))
      offset_def = @entry.at_xpath('./cda:pauseQuantity', HQMF2::Document::NAMESPACES)
      @offset = Value.new(offset_def) if offset_def
    end
    
    def to_json
      json = build_hash(self, [:type])
      json[:offset] = self.offset.to_json if self.offset
      json[:reference] = self.reference.to_json if self.reference
      json
    end    
  end

  # Represents a HQMF reference from a precondition to a data criteria
  class Reference
    include HQMF2::Utilities
    
    def initialize(entry)
      @entry = entry
    end
    
    def id
      attr_val('./@extension')
    end
    
    def to_json
      build_hash(self, [:id])
    end
  end
  
end