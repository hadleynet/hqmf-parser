module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class DocumentConverter
   
    def self.convert(json)
     
      # Create a new HQMF::Document which can be converted to JavaScript
      # @param [String] title
      # @param [String] description
      # @param [Array#PopulationCritera] population_criteria 
      # @param [Array#DataCriteria] data_criteria
      # @param [Range] measure_period
     
     
      title = json[:title]
      description = json[:description]
      
      metadata = json[:metadata]
      metadata.keys.each {|key| metadata[key.to_s] = metadata[key]; metadata.delete(key.to_sym)}
      
      id = metadata["NQF_ID_NUMBER"][:value] if metadata["NQF_ID_NUMBER"]

      attributes = []
      
      metadata.keys.each do |key|
        attribute_hash = metadata[key]
        code = attribute_hash[:code]
        value = attribute_hash[:value]
        unit = attribute_hash[:unit]
        name = attribute_hash[:name]
        attributes << HQMF::Attribute.new(id,code,value,unit,name)
      end

      data_criteria_by_id = {}

      data_criteria = parse_data_criteria(json, data_criteria_by_id)

      measure_period = parse_measure_period(json)
      create_measure_period_variables(json,measure_period,data_criteria,data_criteria_by_id)
      
      population_criteria = parse_population_criteria(json,data_criteria_by_id)
      
      
      HQMF::Document.new(id, title, description, population_criteria, data_criteria, attributes, measure_period)
     
    end
    
    private
    
    def self.parse_data_criteria(json, data_criteria_by_id)
      data_criteria = []
      json[:data_criteria].each do |key,criteria|
        parsed_criteria = HQMF::DataCriteriaConverter.convert(key, criteria)
        data_criteria << parsed_criteria
        data_criteria_by_id[criteria[:id]] = parsed_criteria
      end
      data_criteria
    end

    def self.parse_population_criteria(json,data_criteria_by_id)
      population_criteria = []
      json[:logic].each do |key,criteria|
        population_criteria << HQMF::PopulationCriteriaConverter.convert(key.to_s, criteria,data_criteria_by_id)
      end
      population_criteria
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
    
    def self.create_measure_period_variables(json,measure_period,data_criteria,data_criteria_by_id)

      Kernel.warn "Creating variables for measure period... not sure if this is right"
      
      attributes = json[:attributes]
      attributes.keys.each {|key| attributes[key.to_s] = attributes[key]}
      
      measure_period_key = attributes['MEASUREMENT_PERIOD'][:id]
      measure_start_key = attributes['MEASUREMENT_START_DATE'][:id]
      measure_end_key = attributes['MEASUREMENT_END_DATE'][:id]
      
      type = 'variable'
      code_list_id = nil
      property = nil
      status = nil
      effective_time = nil
      inline_code_list = nil
      subset_code = nil
      
      #####
      ##
      ######### START DATE / END DATE VARIABLES
      ##
      #####
      
      # value = HQMF::Value.new('TS',nil,measure_period.low.value,nil, nil, nil)
      # data_criteria << HQMF::DataCriteria.new('StartDate','StartDate',section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      # 
      # value = HQMF::Value.new('TS',nil,measure_period.high.value,nil, nil, nil)
      # data_criteria << HQMF::DataCriteria.new('EndDate','EndDate',section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      
      

      #####
      ##
      ######### SET MEASURE PERIOD
      ##
      #####
      
      value = measure_period
      measure_criteria = HQMF::DataCriteria.new('MeasurePeriod','MeasurePeriod','MeasurePeriod','MeasurePeriod',subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list, false,[])
      
      # set the measure period data criteria for all measure period keys
      data_criteria_by_id[measure_period_key] = measure_criteria
      data_criteria_by_id[measure_start_key] = measure_criteria
      data_criteria_by_id[measure_end_key] = measure_criteria
      
    end

   
  end  
end
