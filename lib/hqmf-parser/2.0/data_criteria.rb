module HQMF2
  # Represents a data criteria specification
  class DataCriteria
  
    include HQMF2::Utilities
    
    attr_reader :property, :type, :status, :value, :effective_time, :section, :temporal_references, :subset_operators, :children_criteria, :derivation_operator
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(entry)
      @entry = entry
      @status = attr_val('./*/cda:statusCode/@code')
      @effective_time = extract_effective_time
      @temporal_references = extract_temporal_references
      @derivation_operator = extract_derivation_operator
      @subset_operators = extract_subset_operators
      @children_criteria = extract_child_criteria
      @id_xpath = './cda:observationCriteria/cda:id/@extension'
      @code_list_xpath = './cda:observationCriteria/cda:code'
      @value_xpath = './cda:observationCriteria/cda:value'
      
      entry_type = attr_val('./*/cda:definition/*/cda:id/@extension')
      case entry_type
      when 'Problem', 'Problems'
        @type = :conditions
        @code_list_xpath = './cda:observationCriteria/cda:value'
        @section = 'conditions'
      when 'Encounter', 'Encounters'
        @type = :encounters
        @id_xpath = './cda:encounterCriteria/cda:id/@extension'
        @code_list_xpath = './cda:encounterCriteria/cda:code'
        @section = 'encounters'
      when 'LabResults', 'Results'
        @type = :results
        @value = extract_value
        @section = 'results'
      when 'Procedure', 'Procedures'
        @id_xpath = './cda:procedureCriteria/cda:id/@extension'
        @code_list_xpath = './cda:procedureCriteria/cda:code'
        @type = :procedures
        @section = 'procedures'
      when 'Medication', 'Medications'
        @type = :medications
        @id_xpath = './cda:substanceAdministrationCriteria/cda:id/@extension'
        @code_list_xpath = './cda:substanceAdministrationCriteria/cda:participant/cda:roleParticipant/cda:code'
        @section = 'medications'
      when 'RX'
        @type = :medication_supply
        @id_xpath = './cda:supplyCriteria/cda:id/@extension'
        @code_list_xpath = './cda:supplyCriteria/cda:participant/cda:roleParticipant/cda:code'
        @section = 'medications'
      when 'Demographics'
        @type = :characteristic
        @property = property_for_demographic
        @value = extract_value
      when 'Derived'
        @type = :derived
      when nil
        @type = :variable
        @value = extract_value
      else
        raise "Unknown data criteria template identifier [#{entry_type}]"
      end
    end
    
    def to_s
      props = {
        :property => property,
        :type => type,
        :status => status,
        :section => section
      }
      "DataCriteria#{props.to_s}"
    end
    
    # Get the identifier of the criteria, used elsewhere within the document for referencing
    # @return [String] the identifier of this data criteria
    def id
      attr_val(@id_xpath)
    end
    
    # Get the title of the criteria, provides a human readable description
    # @return [String] the title of this data criteria
    def title
      @entry.at_xpath('./cda:localVariableName', HQMF2::Document::NAMESPACES).inner_text
    end
    
    # Get the code list OID of the criteria, used as an index to the code list database
    # @return [String] the code list identifier of this data criteria
    def code_list_id
      attr_val("#{@code_list_xpath}/@valueSet")
    end
    
    def inline_code_list
      codeSystem = attr_val("#{@code_list_xpath}/@codeSystem")
      if codeSystem
        codeSystemName = HealthDataStandards::Util::CodeSystemHelper.code_system_for(codeSystem)
      else
        codeSystemName = attr_val("#{@code_list_xpath}/@codeSystemName")
      end
      codeValue = attr_val("#{@code_list_xpath}/@code")
      if codeSystemName && codeValue
        {codeSystemName => [codeValue]}
      else
        nil
      end
    end
    
    def to_model
      mv = value ? value.to_model : nil
      met = effective_time ? effective_time.to_model : nil
      negation = false
      mtr = temporal_references.collect {|ref| ref.to_model}
      mso = subset_operators.collect {|opr| opr.to_model}
      HQMF::DataCriteria.new(id, title, nil, nil, nil, code_list_id, children_criteria, derivation_operator, property, type, status, mv, met, inline_code_list, negation, mtr, mso)
    end
    
    private
    
    def extract_child_criteria
      @entry.xpath('./*/cda:excerpt/*/cda:id', HQMF2::Document::NAMESPACES).collect do |ref|
        Reference.new(ref).id
      end.compact
    end
    
    def extract_effective_time
      effective_time_def = @entry.at_xpath('./*/cda:effectiveTime', HQMF2::Document::NAMESPACES)
      if effective_time_def
        EffectiveTime.new(effective_time_def)
      else
        nil
      end
    end
    
    def all_subset_operators
      @entry.xpath('./*/cda:excerpt', HQMF2::Document::NAMESPACES).collect do |subset_operator|
        SubsetOperator.new(subset_operator)
      end
    end
    
    def extract_derivation_operator
      derivation_operators = all_subset_operators.select do |operator|
        ['UNION', 'XPRODUCT'].include?(operator.type)
      end
      raise "More than one derivation operator in data criteria" if derivation_operators.size>1
      derivation_operators.first ? derivation_operators.first.type : nil
    end
    
    def extract_subset_operators
      all_subset_operators.select do |operator|
        operator.type != 'UNION' && operator.type != 'XPRODUCT'
      end
    end
    
    def extract_temporal_references
      @entry.xpath('./*/cda:temporallyRelatedInformation', HQMF2::Document::NAMESPACES).collect do |temporal_reference|
        TemporalReference.new(temporal_reference)
      end
    end
    
    def extract_value
      value = nil
      value_def = @entry.at_xpath(@value_xpath, HQMF2::Document::NAMESPACES)
      if value_def
        value_type_def = value_def.at_xpath('@xsi:type', HQMF2::Document::NAMESPACES)
        if value_type_def
          value_type = value_type_def.value
          case value_type
          when 'TS'
            value = Value.new(value_def)
          when 'IVL_PQ', 'IVL_INT'
            value = Range.new(value_def)
          when 'CD'
            value = Coded.new(value_def)
          else
            raise "Unknown value type [#{value_type}]"
          end
        end
      end
      value
    end
    
    def property_for_demographic
      demographic_type = attr_val('./cda:observationCriteria/cda:code/@code')
      case demographic_type
      when '21112-8'
        :birthtime
      when '424144002'
        :age
      when '263495000'
        :gender
      when '102902016'
        :languages
      when '125680007'
        :maritalStatus
      when '103579009'
        :race
      else
        raise "Unknown demographic identifier [#{demographic_type}]"
      end
    end

  end
  
end