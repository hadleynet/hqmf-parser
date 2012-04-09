module HQMF
  module Utilities
    # Utility function to handle optional attributes
    # @param xpath an XPath that identifies an XML attribute
    # @return the value of the attribute or nil if the attribute is missing
    def attr_val(xpath)
      attr = @entry.at_xpath(xpath)
      if attr
        attr.value
      else
        nil
      end
    end
    
    def to_xml
      @entry.to_xml
    end
    
    def json_array(elements) 
      array = []
      elements.each {|element| array << element.to_json }
      array.compact!
      (array.empty?) ? nil : array
      array
    end
    
    def build_hash(source, elements)
      hash = {}
      elements.each do |element|
        value = source.send(element)
        hash[element] = value if value
      end
      hash
    end
    
    def clean_json(json)
      json.reject!{|k,v| v.nil? || (v.respond_to?(:empty?) && v.empty?)}
    end
    
    def clean_json_recursive(json)
      json.each do |k,v|
        if v.is_a? Hash
          clean_json_recursive(v)
          clean_json(v)
        elsif v.is_a? Array
          v.each do |e|
            if e.is_a? Hash
              clean_json_recursive(e)
              clean_json(e)
            end
          end
        end
        
      end
      clean_json(json)
    end
    
    [{:conjunction=>"AND",
          :preconditions=>
           [{:conjunction=>"OR",
             :comparison=>
              {:data_criteria_id=>"10165EC8-53EE-4242-A20D-B1D21CE0DC73",
               :title=>"Medication, Administered: Pneumococcal Vaccine all ages",
               :restrictions=>
                [{:type=>"DURING",
                  :target_id=>"F8D5AD22-F49E-4181-B886-E5B12BEA8966"}]},
             :restrictions=>
              [{:type=>"DURING",
                :target_id=>"F8D5AD22-F49E-4181-B886-E5B12BEA8966"}]},
            {:conjunction=>"OR",
             :comparison=>
              {:data_criteria_id=>"482902EC-E214-4FB4-8C5A-85A41250573C",
               :title=>"Procedure, Performed: Pneumococcal Vaccination all ages",
               :restrictions=>
                [{:type=>"DURING",
                  :target_id=>"F8D5AD22-F49E-4181-B886-E5B12BEA8966"}]},
             :restrictions=>
              [{:type=>"DURING",
                :target_id=>"F8D5AD22-F49E-4181-B886-E5B12BEA8966"}]}],
          :restrictions=>
           [{:type=>"DURING",
             :target_id=>"F8D5AD22-F49E-4181-B886-E5B12BEA8966"}]}]
    def collapse_logical_operators(operators)
      collapsed = []
      operators_by_type = {}
      operators.each do |operator|
        operators_by_type[operator[:conjunction]] ||= []
        operators_by_type[operator[:conjunction]] << operator
      end
      operators_by_type.each do |type, operators|
        collapse = join_like_operators(type, operators)
        collapse[:preconditions] = collapse_logical_operators(collapse[:preconditions]) if collapse[:preconditions]
        collapsed << collapse
      end
      collapsed
    end
    
    def join_like_operators(type, operators)
      operator = {}
      operator[:conjunction] = type
      operators.each do |current|
        if (current[:comparison])
          comparison = current[:comparison]
          comparison[:negation] = current[:negation] if current[:negation]
          operator[:comparisons] ||= []
          operator[:comparisons] << comparison
        end
        operator[:preconditions] = current[:preconditions]
        # restrictions have been pushed down
        # operator[:restrictions] = current[:restrictions] if current[:restrictions]
      end
      operator
    end
    
  end
end  