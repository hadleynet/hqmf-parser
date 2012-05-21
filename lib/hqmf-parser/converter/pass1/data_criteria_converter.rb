module HQMF
  # Class representing an HQMF document
  class DataCriteriaConverter

    attr_reader :v1_data_criteria_by_id, :v2_data_criteria, :v2_data_criteria_to_delete

    def initialize(doc, measure_period)
      @doc = doc
      @v1_data_criteria_by_id = {}
      @v2_data_criteria = []
      @v2_data_criteria_to_delete = []
      @measure_period = measure_period
      parse()
    end

    def final_v2_data_criteria
      v2_data_criteria.delete_if {|criteria| @v2_data_criteria_to_delete.include? criteria.id }
    end

    def duplicate_data_criteria(data_criteria, scope, parent_id)
      new_data_criteria = data_criteria.clone
      new_data_criteria.id = "#{new_data_criteria.id}_#{scope}_#{parent_id}"
      @v2_data_criteria << new_data_criteria
      # we want to delete the original for data criteria that have been duplicated
      @v2_data_criteria_to_delete << data_criteria.id
      new_data_criteria
    end
    
    def create_group_data_criteria(children_criteria, type, value, parent_id, id, standard_category, qds_data_type)
      criteria_ids = children_criteria.map(&:id)
      clean_ids = criteria_ids.map {|key| key.gsub /_precondition_\d+/, ''}
      
      value_string = (value.stringify if value) || ""
      id = "#{parent_id}_#{type}_#{id}"
      title = "#{id}#{value_string}"
      description = "#{type}(#{clean_ids.join(',')})#{value_string}"
      _subset_code,_subset_value,_code_list_id,_property,_type,_status,_value,_effective_time,_inline_code_list,_negation = nil
      
      group_criteria = HQMF::DataCriteria.new(id, title, description, standard_category, qds_data_type, _code_list_id, criteria_ids, _property,
                                              _type, _status, _value, _effective_time, _inline_code_list,_negation,nil,nil)
      
      @v2_data_criteria << group_criteria
      group_criteria
    end
    
    def v2_data_criteria_by_id
      criteria_by_id = {}
      @v2_data_criteria.each do |criteria|
        criteria_by_id[criteria.id] = criteria
      end
      criteria_by_id
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
      
      value = nil # value is filled out by backfill_patient_characteristics for things like gender
      effective_time = nil # filled out by temporal reference code
      temporal_references = # filled out by operator code
      subset_operators = nil # filled out by operator code
      children_criteria = nil # filled out by operator and temporal reference code

      inline_code_list = nil # inline code list is only used in HQMF V2, so we can just pass in nil

      HQMF::DataCriteria.new(id, title, description, standard_category, qds_data_type, 
        code_list_id, children_criteria, property,type, status, value, effective_time, inline_code_list,
        negation, temporal_references, subset_operators)
 
    end
    
    
    # this method creates V1 data criteria for the measurement period.  These data criteria can be
    # referenced properly within the restrictions
    def self.create_measure_period_v1_data_criteria(doc,measure_period,v1_data_criteria_by_id)

      attributes = doc[:attributes]
      attributes.keys.each {|key| attributes[key.to_s] = attributes[key]}
      
      measure_period_key = attributes['MEASUREMENT_PERIOD'][:id]
      measure_start_key = attributes['MEASUREMENT_START_DATE'][:id]
      measure_end_key = attributes['MEASUREMENT_END_DATE'][:id]
      
      type = 'variable'
      code_list_id,property,status,effective_time,inline_code_list,children_criteria,temporal_references,subset_operators=nil
      
      #####
      ##
      ######### SET MEASURE PERIOD
      ##
      #####
      
      measure_period_id = HQMF::Document::MEASURE_PERIOD_ID
      value = measure_period
      measure_criteria = HQMF::DataCriteria.new(measure_period_id,measure_period_id,measure_period_id,measure_period_id,measure_period_id,code_list_id,children_criteria,property,type,status,value,effective_time,inline_code_list, false,temporal_references,subset_operators)
      
      # set the measure period data criteria for all measure period keys
      v1_data_criteria_by_id[measure_period_key] = measure_criteria
      v1_data_criteria_by_id[measure_start_key] = measure_criteria
      v1_data_criteria_by_id[measure_end_key] = measure_criteria
      
    end

    
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
          :unknown
        else
          raise "unsupported data criteria property conversion: #{property}"
      end
    end

    def self.convert_key(key)
      key.to_s.downcase.gsub('_', ' ').split(' ').map {|w| w.capitalize }.join('')
    end 
    
  end
end
