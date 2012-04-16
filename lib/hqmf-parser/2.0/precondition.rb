module HQMF2
  
  class Precondition
  
    include HQMF2::Utilities
    
    attr_reader :preconditions, :reference
  
    def initialize(entry, doc)
      @doc = doc
      @entry = entry
      @preconditions = @entry.xpath('./*/cda:precondition', HQMF2::Document::NAMESPACES).collect do |precondition|
        Precondition.new(precondition, @doc)
      end
      reference_def = @entry.at_xpath('./*/cda:id', HQMF2::Document::NAMESPACES)
      if reference_def
        @reference = Reference.new(reference_def)
      end
    end
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      @preconditions.length>0
    end
    
    # Get the conjunction code, e.g. allTrue, allFalse
    # @return [String] conjunction code
    def conjunction_code
      @entry.at_xpath('./*[1]', HQMF2::Document::NAMESPACES).name
    end
    
    def to_json
      x = nil
      json = {}
      json[:reference] = self.reference.id if self.reference
      json[:preconditions] = x if x = json_array(@preconditions)
      json[:conjunction_code] = self.conjunction_code if self.conjunction_code
      json
    end
    
    
  end
    
end