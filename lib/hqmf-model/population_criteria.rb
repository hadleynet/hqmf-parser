module HQMF
  # Represents an HQMF population criteria, also supports all the same methods as
  # HQMF::Precondition
  class PopulationCriteria
  
    include HQMF::Conversion::Utilities

    attr_reader :preconditions, :id, :type, :title
    
    # Create a new population criteria
    # @param [String] id
    # @param [Array#Precondition] preconditions 
    # @param [String] title (optional)
    def initialize(id, type, preconditions, title='')
      @id = id
      @preconditions = preconditions
      @type = type
      @title=title
    end
    
    # Create a new population criteria from a JSON hash keyed off symbols
    def self.from_json(id, json)
      preconditions = json["preconditions"].map do |precondition|
        HQMF::Precondition.from_json(precondition)
      end if json['preconditions']
      type = json["type"]
      title = json['title']
      
      HQMF::PopulationCriteria.new(id, type, preconditions, title)
    end
    
    def to_json
      x = nil
      json = build_hash(self, [:conjunction?, :type, :title])
      json[:preconditions] = x if x = json_array(@preconditions)
      {self.id.to_sym => json}
    end
    
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      true
    end

    # Get the conjunction code, e.g. allTrue, atLeastOneTrue
    # @return [String] conjunction code
    def conjunction_code
      if (id.start_with? 'IPP' or id.start_with? 'DENOM' or id.start_with? 'NUMER')
        HQMF::Precondition::ALL_TRUE
      elsif (id.start_with? 'DENEXCEP' or id.start_with? 'EXCL')
        HQMF::Precondition::AT_LEAST_ONE_TRUE
      else
        raise "Unknown population type [#{id}]"
      end
    end
    
    # Can't have negation on population so this is the same as conjunction_code
    def conjunction_code_with_negation
      conjunction_code
    end
    
  end
  
end