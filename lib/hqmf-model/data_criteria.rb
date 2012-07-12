module HQMF
  # Represents a data criteria specification
  class DataCriteria

    include HQMF::Conversion::Utilities

    XPRODUCT = 'XPRODUCT'
    UNION = 'UNION'

    FIELDS = {'SEVERITY'=>{title:'Severity',coded_entry_method: :severity},
              'ORDINAL'=>{title:'Ordinal',coded_entry_method: :ordinal},
              'ENVIRONMENT'=>{title:'Environment',coded_entry_method: :environment},
              'REASON'=>{title:'Reason',coded_entry_method: :reason},
              'RADIATION_DOSAGE'=>{title:'Radiation Dosage',coded_entry_method: :radiation_dosage},
              'RADIATION_DURATION'=>{title:'Radiation Duration',coded_entry_method: :radiation_duration},
              'LENGTH_OF_STAY'=>{title:'Length of Stay',coded_entry_method: :length_of_stay}}

    attr_reader :title,:description,:code_list_id, :children_criteria, :derivation_operator 
    attr_accessor :id, :value, :field_values, :effective_time, :status, :temporal_references, :subset_operators, :definition, :inline_code_list, :negation_code_list_id, :negation, :display_name
  
    # Create a new data criteria instance
    # @param [String] id
    # @param [String] title
    # @param [String] display_name
    # @param [String] description
    # @param [String] code_list_id
    # @param [String] negation_code_list_id
    # @param [List<String>] children_criteria (ids of children data criteria)
    # @param [String] derivation_operator
    # @param [String] definition
    # @param [String] status
    # @param [Value|Range|Coded] value
    # @param [Hash<String,Value|Range|Coded>] field_values
    # @param [Range] effective_time
    # @param [Hash<String,[String]>] inline_code_list
    # @param [boolean] negation
    # @param [String] negation_code_list_id
    # @param [List<TemporalReference>] temporal_references
    # @param [List<SubsetOperator>] subset_operators
    def initialize(id, title, display_name, description, code_list_id, children_criteria, derivation_operator, definition, status, value, field_values, effective_time, inline_code_list, negation, negation_code_list_id, temporal_references, subset_operators)

      status = normalize_status(definition, status)
      @settings = get_settings_for_definition(definition, status)

      @id = id
      @title = title
      @description = description
      @code_list_id = code_list_id
      @negation_code_list_id = negation_code_list_id
      @children_criteria = children_criteria
      @derivation_operator = derivation_operator
      @definition = definition
      @status = status
      @value = value
      @field_values = field_values
      @effective_time = effective_time
      @inline_code_list = inline_code_list
      @negation = negation
      @negation_code_list_id = negation_code_list_id
      @temporal_references = temporal_references
      @subset_operators = subset_operators
    end
    
    def standard_category
      @settings['standard_category']
    end
    def qds_data_type
      @settings['qds_data_type']
    end
    def type
      @settings['category'].to_sym
    end
    def property
      @settings['property'].to_sym unless @settings['property'].nil?
    end
    def patient_api_function
      @settings['patient_api_function'].to_sym unless @settings['patient_api_function'].empty?
    end
    
    def definition=(definition)
      @definition = definition
      @settings = get_settings_for_definition(@definition, @status)
    end
    def status=(status)
      @status = status
      @settings = get_settings_for_definition(@definition, @status)
    end

    # Create a new data criteria instance from a JSON hash keyed with symbols
    def self.from_json(id, json)
      title = json["title"] if json["title"]
      display_name = json["display_name"] if json["display_name"]
      description = json["description"] if json["description"]
      code_list_id = json["code_list_id"] if json["code_list_id"]
      children_criteria = json["children_criteria"] if json["children_criteria"]
      derivation_operator = json["derivation_operator"] if json["derivation_operator"]
      definition = json["definition"] if json["definition"]
      status = json["status"] if json["status"]
      value = convert_value(json["value"]) if json["value"]
      field_values = json["field_values"].inject({}){|memo,(k,v)| memo[k.to_s] = convert_value(v); memo} if json["field_values"]
      effective_time = HQMF::Range.from_json(json["effective_time"]) if json["effective_time"]
      inline_code_list = json["inline_code_list"].inject({}){|memo,(k,v)| memo[k.to_s] = v; memo} if json["inline_code_list"]
      negation = json["negation"] || false
      negation_code_list_id = json['negation_code_list_id'] if json['negation_code_list_id']
      temporal_references = json["temporal_references"].map {|reference| HQMF::TemporalReference.from_json(reference)} if json["temporal_references"]
      subset_operators = json["subset_operators"].map {|operator| HQMF::SubsetOperator.from_json(operator)} if json["subset_operators"]

      HQMF::DataCriteria.new(id, title, display_name, description, code_list_id, children_criteria, derivation_operator, definition, status, value, field_values,
                             effective_time, inline_code_list, negation, negation_code_list_id, temporal_references, subset_operators)
    end

    def to_json
      json = base_json
      {self.id.to_s.to_sym => json}
    end

    def base_json
      x = nil
      json = build_hash(self, [:title,:display_name,:description,:standard_category,:qds_data_type,:code_list_id,:children_criteria, :derivation_operator, :property, :type, :definition, :status, :negation, :negation_code_list_id])
      json[:children_criteria] = @children_criteria unless @children_criteria.nil? || @children_criteria.empty?
      json[:value] = ((@value.is_a? String) ? @value : @value.to_json) if @value
      json[:field_values] = @field_values.inject({}) {|memo,(k,v)| memo[k] = v.to_json; memo} if @field_values
      json[:effective_time] = @effective_time.to_json if @effective_time
      json[:inline_code_list] = @inline_code_list if @inline_code_list
      json[:temporal_references] = x if x = json_array(@temporal_references)
      json[:subset_operators] = x if x = json_array(@subset_operators)
      json
    end

    def has_temporal(temporal_reference)
      @temporal_references.reduce(false) {|found, item| found ||= item == temporal_reference }
    end
    def has_subset(subset_operator)
      @subset_operators.reduce(false) {|found, item| found ||= item == subset_operator }
    end

    private

    def normalize_status(definition, status)
      return status if status.nil?
      case status.downcase
        when 'completed', 'complete'
          case definition
            when 'diagnosis'
              'active'
            else
              'performed'
            end
        when 'order'
          'ordered'
        else
          status.downcase
      end
    end

    def get_settings_for_definition(definition, status)
      settings_file = File.expand_path('../data_criteria.json', __FILE__)
      settings_map = JSON.parse(File.read(settings_file))
      key = definition + ((status.nil? || status.empty?) ? '' : "_#{status}")
      settings = settings_map[key]
      
      raise "data criteria is not supported #{key}" if settings.nil? || settings["not_supported"]

      settings
    end

    def self.convert_value(json)
      return nil unless json
      value = nil
      type = json["type"]
      case type
        when 'TS'
          value = HQMF::Value.from_json(json)
        when 'IVL_PQ'
          value = HQMF::Range.from_json(json)
        when 'CD'
          value = HQMF::Coded.from_json(json)
        else
          raise "Unknown value type [#{type}]"
        end
      value
    end


  end

end
