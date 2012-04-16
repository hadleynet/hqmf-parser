module HQMF
  
  class Precondition
  
    attr_reader :preconditions, :reference, :conjunction_code
  
    # Create a new population criteria
    # @param [Array#Precondition] preconditions 
    # @param [Reference] reference
    # @param [String] conjunction_code
    def initialize(preconditions,reference,conjunction_code)
      @preconditions = preconditions || []
      @reference = reference
      @conjunction_code = conjunction_code
    end
    
    # Create a new population criteria from a JSON hash keyed off symbols
    def self.from_json(json)
      preconditions = []
      preconditions = json[:preconditions].map {|preciondition| JSON::Precondition.from_json(preciondition)} if json[:preconditions]
      reference = Reference.new(json[:reference]) if json[:reference] 
      conjunction_code = json[:conjunction_code] if json[:conjunction_code]
      
      JSON::Precondition.new(preconditions,reference,conjunction_code)
    end
    def to_json
      x = nil
      json = {}
      json[:reference] = self.reference.id if self.reference
      json[:preconditions] = x if x = json_array(@preconditions)
      json[:conjunction_code] = self.conjunction_code if self.conjunction_code
      json
    end
    
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      @preconditions.length>0
    end
    
  end
    
end