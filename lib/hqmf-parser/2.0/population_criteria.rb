module HQMF2
  # Represents an HQMF population criteria, also supports all the same methods as
  # HQMF2::Precondition
  class PopulationCriteria
  
    include HQMF2::Utilities
    
    attr_reader :preconditions
    
    # Create a new population criteria from the supplied HQMF entry
    # @param [Nokogiri::XML::Element] the HQMF entry
    def initialize(entry, doc)
      @doc = doc
      @entry = entry
      @preconditions = @entry.xpath('./*/cda:precondition', HQMF2::Document::NAMESPACES).collect do |precondition|
        Precondition.new(precondition, @doc)
      end
    end
    
    # Get the id for the population criteria
    # @return [String] the id
    def id
      attr_val('./*/cda:id/@extension')
    end
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      true
    end

    # Get the conjunction code, e.g. allTrue, allFalse
    # @return [String] conjunction code
    def conjunction_code
      case id
      when 'IPP', 'DENOM', 'NUMER'
        'allTrue'
      when 'DENEXCEP'
        'atLeastOneTrue'
      else
        raise "Unknown population type [#{id}]"
      end
    end
    
    def to_json
      x = nil
      json = build_hash(self, [:conjunction?])
      json[:preconditions] = x if x = json_array(@preconditions)
      {self.id.to_sym => json}
    end
    
    def to_model
      mps = preconditions.collect {|p| p.to_model}
      HQMF::PopulationCriteria.new(id, mps)
    end

  end
  
end