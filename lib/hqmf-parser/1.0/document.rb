module HQMF1
  # Class representing an HQMF document
  class Document
    
    include HQMF1::Utilities
    
    # Create a new HQMF1::Document instance by parsing the supplied contents
    # @param [String] hqmf_contents the contents of an HQMF v1.0 document
    def initialize(hqmf_contents)
      @doc = Document.parse(hqmf_contents)
      @data_criteria = @doc.xpath('//cda:section[cda:code/@code="57025-9"]/cda:entry').collect do |entry|
        DataCriteria.new(entry)
      end
      
      backfill_derived_code_lists
      
      @attributes = @doc.xpath('//cda:subjectOf/cda:measureAttribute').collect do |attr|
        Attribute.new(attr)
      end
      @population_criteria = @doc.xpath('//cda:section[cda:code/@code="57026-7"]/cda:entry').collect do |attr|
        PopulationCriteria.new(attr, self)
      end
    end
    
    # Get the title of the measure
    # @return [String] the title
    def title
      @doc.at_xpath('cda:QualityMeasureDocument/cda:title').inner_text
    end
    
    # Get the description of the measure
    # @return [String] the description
    def description
      @doc.at_xpath('cda:QualityMeasureDocument/cda:text').inner_text
    end
  
    # Get all the attributes defined by the measure
    # @return [Array] an array of HQMF1::Attribute
    def all_attributes
      @attributes
    end
    
    # Get a specific attribute by id.
    # @param [String] id the attribute identifier
    # @return [HQMF1::Attribute] the matching attribute, raises an Exception if not found
    def attribute(id)
      find(@attributes, :id, id)
    end
    
    # Get a specific attribute by code.
    # @param [String] code the attribute code
    # @return [HQMF1::Attribute] the matching attribute, raises an Exception if not found
    def attribute_for_code(code)
      find(@attributes, :code, code)
    end

    # Get all the population criteria defined by the measure
    # @return [Array] an array of HQMF1::PopulationCriteria
    def all_population_criteria
      @population_criteria
    end
    
    # Get a specific population criteria by id.
    # @param [String] id the population identifier
    # @return [HQMF1::PopulationCriteria] the matching criteria, raises an Exception if not found
    def population_criteria(id)
      find(@population_criteria, :id, id)
    end
    
    # Get a specific population criteria by code.
    # @param [String] code the population criteria code
    # @return [HQMF1::PopulationCriteria] the matching criteria, raises an Exception if not found
    def population_criteria_for_code(code)
      find(@population_criteria, :code, code)
    end

    # Get all the data criteria defined by the measure
    # @return [Array] an array of HQMF1::DataCriteria describing the data elements used by the measure
    def all_data_criteria
      @data_criteria
    end
    
    # Get a specific data criteria by id.
    # @param [String] id the data criteria identifier
    # @return [HQMF1::DataCriteria] the matching data criteria, raises an Exception if not found
    def data_criteria(id)
      val = find(@data_criteria, :id, id) || raise("unknown data criteria #{id}")
    end
    
    # Parse an XML document from the supplied contents
    # @return [Nokogiri::XML::Document]
    def self.parse(hqmf_contents)
      doc = Nokogiri::XML(hqmf_contents)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc
    end
    
    # if the data criteria is derived from another criteria, then we want to grab the properties from the derived criteria
    # this is typically the case with Occurrence A, Occurrence B type data criteria
    def backfill_derived_code_lists
      data_criteria_by_id = {}
      @data_criteria.each {|criteria| data_criteria_by_id[criteria.id] = criteria}
      @data_criteria.each do |criteria|
        if (criteria.derived_from)
          derived_from = data_criteria_by_id[criteria.derived_from]
          criteria.property = derived_from.property
          criteria.type = derived_from.type
          criteria.status = derived_from.status
          criteria.standard_category = derived_from.standard_category
          criteria.qds_data_type = derived_from.qds_data_type
          criteria.code_list_id = derived_from.code_list_id
        end
      end
    end

    def to_json
      json = build_hash(self, [:title, :description])
      
      json[:data_criteria] = {}
      @data_criteria.each do |criteria|
        json[:data_criteria].merge! criteria.to_json
      end
      
      json[:metadata] = {}
      json[:attributes] = {}
      @attributes.each do |attribute|
        if (attribute.id)
          json[:attributes].merge! attribute.to_json
        else
          json[:metadata].merge! attribute.to_json
        end
          
      end

      json[:logic] = {}
      counters = {}
      @population_criteria.each do |population|
        population_json = population.to_json
        key = population_json.keys.first
        if json[:logic][key]
          counters[key] ||= 0
          counters[key] += 1
          population_json["#{key}_#{counters[key]}"] = population_json[key]
          population_json.delete(key)
        end
        json[:logic].merge! population_json
      end
      
      clean_json_recursive(json)
      json
    end
    
    private
    
    def find(collection, attribute, value)
      collection.find {|e| e.send(attribute)==value}
    end
    
  end
end