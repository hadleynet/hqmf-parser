module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class DocumentConverter
   
    
    def self.convert(json, codes)
      
      title = json[:title]
      description = json[:description]
      
      metadata = json[:metadata]
      metadata.keys.each {|key| metadata[key.to_s] = metadata[key]; metadata.delete(key.to_sym)}
      
      id = metadata["NQF_ID_NUMBER"][:value] if metadata["NQF_ID_NUMBER"]
      attributes = parse_attributes(metadata)
      
      measure_period = parse_measure_period(json)
      @data_criteria_converter = DataCriteriaConverter.new(json, measure_period)
      
      data_criteria_by_id = @data_criteria_converter.v1_data_criteria_by_id
      
      @population_criteria_converter = PopulationCriteriaConverter.new(json, @data_criteria_converter)
      population_criteria = @population_criteria_converter.population_criteria
      
      comparison_converter = HQMF::ComparisonConverter.new(@data_criteria_converter)
      comparison_converter.convert_comparisons(population_criteria)

      data_criteria = @data_criteria_converter.final_v2_data_criteria
      
      # Create a new HQMF::Document which can be converted to JavaScript
      # @param [String] title
      # @param [String] description
      # @param [Array#PopulationCritera] population_criteria 
      # @param [Array#DataCriteria] data_criteria
      # @param [Range] measure_period
      doc = HQMF::Document.new(id, title, description, population_criteria, data_criteria, attributes, measure_period)
       
      backfill_patient_characteristics_with_codes(doc, codes) if (codes)
      
      doc
      
    end
   
    private
    
    def self.parse_attributes(metadata)
      attributes = []
      metadata.keys.each do |key|
        attribute_hash = metadata[key]
        code = attribute_hash[:code]
        value = attribute_hash[:value]
        unit = attribute_hash[:unit]
        name = attribute_hash[:name]
        attributes << HQMF::Attribute.new(key,code,value,unit,name)
      end
      attributes
    end
    

    # patient characteristics data criteria such as GENDER require looking at the codes to determine if the 
    # measure is interested in Males or Females.  This process is awkward, and thus is done as a separate
    # step after the document has been converted.
    def self.backfill_patient_characteristics_with_codes(doc, codes)
      doc.all_data_criteria.each do |data_criteria|
        if (data_criteria.type == :characteristic and data_criteria.property.nil?)
          value_set = codes[data_criteria.code_list_id]
          raise "no value set for unknown patient characteristic: #{data_criteria.id}" unless value_set
          
          # looking for Gender: Female
          if value_set["HL7"] and value_set["HL7"] == ["10174"]
            data_criteria.property = :gender
            data_criteria.value = HQMF::Coded.new('CD','Gender','F')
          else
            data_criteria.type = :allProblems
            Kernel.warn "backfilled data criteria: #{data_criteria.id}"
          end
          
        end
      end
    end
    

    def self.parse_measure_period(json)
      
      # Create a new HQMF::EffectiveTime
      # @param [Value] low
      # @param [Value] high
      # @param [Value] width
      # ----------
      # Create a new HQMF::Value
      # @param [String] type
      # @param [String] unit
      # @param [String] value
      # @param [String] inclusive
      # @param [String] derived
      # @param [String] expression
      
      low = HQMF::Value.new('TS',nil,'20100101',nil, nil, nil)
      high = HQMF::Value.new('TS',nil,'20101231',nil, nil, nil)
      width = HQMF::Value.new('PQ','a','1',nil, nil, nil)
      
      Kernel.warn('need to figure out a way to make dates dynamic')
      
      HQMF::EffectiveTime.new(low,high,width)
    end
    

   
  end  
end
