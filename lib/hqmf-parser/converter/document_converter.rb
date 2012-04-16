module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class DocumentConverter
   
    def self.convert(json)
     
      # Create a new JSON::Document which can be converted to JavaScript
      # @param [String] title
      # @param [String] description
      # @param [Array#PopulationCritera] population_criteria 
      # @param [Array#DataCriteria] data_criteria
      # @param [Range] measure_period
     
     
      title = json[:title]
      description = json[:description]

      data_criteria_by_id = {}

      data_criteria = parse_data_criteria(json, data_criteria_by_id)

      measure_period = parse_measure_period(json)
      create_measure_period_variables(json,measure_period,data_criteria,data_criteria_by_id)
      
      population_criteria = parse_population_criteria(json,data_criteria_by_id)
      
      
      JSON::Document.new(title, description, population_criteria, data_criteria, measure_period)
     
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
      
      # Create a new JSON::EffectiveTime
      # @param [Value] low
      # @param [Value] high
      # @param [Value] width
      # ----------
      # Create a new JSON::Value
      # @param [String] type
      # @param [String] unit
      # @param [String] value
      # @param [String] inclusive
      # @param [String] derived
      # @param [String] expression
      
      low = JSON::Value.new('TS',nil,'20120101',nil, nil, nil)
      high = JSON::Value.new('TS',nil,'20121231',nil, nil, nil)
      width = JSON::Value.new('PQ','a','1',nil, nil, nil)
      
      Kernel.warn('need to figure out a way to make dates dynamic')
      
      JSON::EffectiveTime.new(low,high,width)
    end
    
    def self.create_measure_period_variables(json,measure_period,data_criteria,data_criteria_by_id)

      Kernel.warn "Creating variables for measure period... not sure if this is right"

      measure_period_key = json[:attributes][:MEASUREMENT_PERIOD][:id]
      measure_start_key = json[:attributes][:MEASUREMENT_START_DATE][:id]
      measure_end_key = json[:attributes][:MEASUREMENT_END_DATE][:id]
      
      type = 'variable'
      section = nil
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
      
      value = JSON::Value.new('TS',nil,measure_period.low.value,nil, nil, nil)
      data_criteria << JSON::DataCriteria.new('StartDate','StartDate',section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)

      value = JSON::Value.new('TS',nil,measure_period.high.value,nil, nil, nil)
      data_criteria << JSON::DataCriteria.new('EndDate','EndDate',section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      
      

      #####
      ##
      ######### SET MEASURE PERIOD
      ##
      #####
      
      value = measure_period
      measure_criteria = JSON::DataCriteria.new('EndDate','EndDate',section,subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list)
      
      # set the measure period data criteria for all measure period keys
      data_criteria_by_id[measure_period_key] = measure_criteria
      data_criteria_by_id[measure_start_key] = measure_criteria
      data_criteria_by_id[measure_end_key] = measure_criteria
      
    end

   
  end  
end
