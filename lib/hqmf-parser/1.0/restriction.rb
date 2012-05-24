module HQMF1
  # Represents a restriction on the allowable values of a data item
  class Restriction
  
    include HQMF1::Utilities
    
    attr_reader :range, :comparison, :restrictions, :subset, :preconditions
    attr_accessor :from_parent
    
    def initialize(entry, parent, doc)
      @doc = doc
      @entry = entry
      @restrictions = []
      
      range_def = @entry.at_xpath('./cda:pauseQuantity')
      if range_def
        @range = Range.new(range_def)
      end
      
      local_restrictions = @entry.xpath('./*/cda:sourceOf[@typeCode!="PRCN" and @typeCode!="COMP"]').collect do |entry|
        Restriction.new(entry, self, @doc)
      end
      
      @restrictions.concat(local_restrictions)
      
      #get subsets and push them down to comparisons
      if (parent)
        @subset = parent.subset
      end
      local_subset = attr_val('./cda:subsetCode/@code')
      if local_subset
        @subset = local_subset
      end
      
      #@subset = attr_val('./cda:subsetCode/@code')
      
      comparison_def = @entry.at_xpath('./*/cda:sourceOf[@typeCode="COMP"]')
      if comparison_def
        data_criteria_id = attr_val('./*/cda:id/@root')
        data_criteria_id = comparison_def.at_xpath('./*/cda:id/@root').value if (data_criteria_id.nil? and comparison_def.at_xpath('./*/cda:id/@root'))
        @comparison = Comparison.new(data_criteria_id, comparison_def, self, @doc)
      end
      
      @preconditions = @entry.xpath('./*/cda:sourceOf[@typeCode="PRCN"]').collect do |entry|
        # create a dummy parent with a single restriction copied from self minus the
        # nested preconditions to avoid an infinite loop
        prior_comparison = nil
        if parent.class==HQMF1::Precondition
          prior_comparison = parent.first_comparison
        else
          prior_comparison = @comparsion
        end
        current_restriction = OpenStruct.new(
          'range' => @range,
          'comparison' => prior_comparison,
          'restrictions' => [],
          'preconditions' => [],
          'subset' => @subset,
          'type' => type,
          'target_id' => target_id,
          'field' => field,
          'value' => value)
        all_restrictions = []
        all_restrictions.concat @restrictions
        all_restrictions << current_restriction
        parent = OpenStruct.new(
          'restrictions' => all_restrictions,
          'subset' => @subset
        )
        p = Precondition.new(entry, parent, @doc)
        
      end
    end
    
    # The type of restriction, e.g. SBS, SBE etc
    def type
      attr_val('./@typeCode')
    end

    # is this type negated? true or false
    def negation
      attr_val('./@inversionInd') == "true"
    end
    
    # The id of the data criteria or measurement property that the value
    # will be compared against
    def target_id
      attr_val('./*/cda:id/@root')
    end
    
    def field
      attr_val('./cda:observation/cda:code/@displayName')
    end
    
    def value
      attr_val('./cda:observation/cda:value/@displayName')
    end
    
    def to_json 
      return nil if from_parent
      json = build_hash(self, [:subset,:type,:target_id,:field,:value,:from_parent, :negation])
      json[:range] = range.to_json if range
      json[:comparison] = comparison.to_json if comparison
      json[:restrictions] = json_array(self.restrictions)
      json[:preconditions] = json_array(self.preconditions)
      json
    end

  end
end