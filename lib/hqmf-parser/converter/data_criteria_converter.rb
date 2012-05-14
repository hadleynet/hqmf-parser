module HQMF
  # Class representing an HQMF document
  class DataCriteriaConverter

    attr_reader :v1_data_criteria_by_id, :v2_data_criteria

    def initialize(doc, measure_period)
      @doc = doc
      @v1_data_criteria_by_id = {}
      @v2_data_criteria = []
      @measure_period = measure_period
      parse()
    end


    private 

    def parse()
      @doc[:data_criteria].each do |key,criteria|
        parsed_criteria = HQMF::DataCriteriaConverter.convert(key, criteria)
        @v2_data_criteria << parsed_criteria
        @v1_data_criteria_by_id[criteria[:id]] = parsed_criteria
      end
      HQMF::DataCriteriaConverter.create_measure_period_v1_data_criteria(@doc,@measure_period,@v1_data_criteria_by_id)
    end

    def self.convert(key, criteria)
 
      # @param [String] id
      # @param [String] title
      # @param [String] standard_category
      # @param [String] qds_data_type
      # @param [String] subset_code
      # @param [String] code_list_id
      # @param [String] property
      # @param [String] type
      # @param [String] status
      # @param [boolean] negation
      # @param [Value|Range|Coded] value
      # @param [Range] effective_time
      # @param [Hash<String,String>] inline_code_list

      id = convert_key(key)
      description = criteria[:title]
      title = title_from_description(description, criteria[:description])
      type = criteria[:type]
      standard_category = criteria[:standard_category]
      qds_data_type = criteria[:qds_data_type]
      code_list_id = criteria[:code_list_id]
      property = convert_data_criteria_property(criteria[:property]) if criteria[:property]
      status = criteria[:status]
      negation = criteria[:negation]
      
      # TODO: NEED TO FINALIZE THESE
      Kernel.warn "We still need to map value, effective_time, inline_code_list, and subset_code"
      value = nil
      effective_time = nil
      inline_code_list = nil
      subset_code = nil
      temporal_references = nil

      HQMF::DataCriteria.new(id, title, description, standard_category, qds_data_type, subset_code, 
        code_list_id, property,type, status, value, effective_time, inline_code_list,
        negation, temporal_references)
 
    end
    
    
    # this method creates V1 data criteria for the measurement period.  These data criteria can be
    # referenced properly within the restrictions
    def self.create_measure_period_v1_data_criteria(doc,measure_period,v1_data_criteria_by_id)

      Kernel.warn "Creating variables for measure period... not sure if this is right"
      
      attributes = doc[:attributes]
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
      ######### SET MEASURE PERIOD
      ##
      #####
      
      value = measure_period
      measure_criteria = HQMF::DataCriteria.new('MeasurePeriod','MeasurePeriod','MeasurePeriod','MeasurePeriod','MeasurePeriod',subset_code,code_list_id,property,type,status,value,effective_time,inline_code_list, false,[])
      
      # set the measure period data criteria for all measure period keys
      v1_data_criteria_by_id[measure_period_key] = measure_criteria
      v1_data_criteria_by_id[measure_start_key] = measure_criteria
      v1_data_criteria_by_id[measure_end_key] = measure_criteria
      
    end
    
    private 
    
    def self.title_from_description(title, description)
      title.gsub(/^#{Regexp.escape(description).gsub('\\ ',':?,?\\ ')}:\s*/i,'')
    end

    def self.convert_data_criteria_property(property)
      case property
        when 'birthtime', :birthtime
          :age
        when 'gender', :gender
          :gender
        when 'unknown', :unknown
          Kernel.warn("data criteria property is unknown")
        else
          raise "unsupported data criteria property conversion: #{property}"
      end
    end

    def self.convert_key(key)
      key.to_s.downcase.gsub('_', ' ').split(' ').map {|w| w.capitalize }.join('')
    end   
  end
end
