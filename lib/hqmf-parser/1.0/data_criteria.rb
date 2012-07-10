module HQMF1
  # Represents a data criteria specification
  class DataCriteria
  
    include HQMF1::Utilities
    
    attr_accessor :code_list_id, :derived_from, :definition, :status, :negation
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(entry)
      @entry = entry
      
      template_map_file = File.expand_path('../data_criteria_template_id_map.json', __FILE__)
      oid_xpath_file = File.expand_path('../data_criteria_oid_xpath.json', __FILE__)
      template_map = JSON.parse(File.read(template_map_file))
      oid_xpath_map = JSON.parse(File.read(oid_xpath_file))
      template_id = attr_val('cda:act/cda:templateId/@root') || attr_val('cda:observation/cda:templateId/@root')
      
      # check to see if this is a derived data criteria.  These are used for multiple occurrences.
      derived_entry = @entry.at_xpath('./*/cda:sourceOf[@typeCode="DRIV"]')
      if derived_entry
        derived = derived_entry.at_xpath('cda:act/cda:id/@root') || derived_entry.at_xpath('cda:observation/cda:id/@root')
        @derived_from = derived.value
        @@occurrences[@derived_from] ||= Counter.new
        @occurrence_key = @@occurrences[@derived_from].next
      end
      
      template = template_map[template_id]
      if template
        @negation=template["negation"]
        @definition=template["definition"]
        @status=template["status"]
        @key=@definition+(@status.empty? ? '' : "_#{@status}")
      else
        raise "Unknown data criteria template identifier [#{template_id}]"
      end
      
      # Get the code list OID of the criteria, used as an index to the code list database
      @code_list_id = attr_val(oid_xpath_map[@key]['oid_xpath'])
      unless @code_list_id
        Kernel.warn "code list id not found, getting default"
        @code_list_id = attr_val('cda:act/cda:sourceOf//cda:code/@code')
      end
      
      Kernel.warn "no oid defined for data criteria: #{@key}" unless @code_list_id
      
    end
    
    # Get the identifier of the criteria, used elsewhere within the document for referencing
    # @return [String] the identifier of this data criteria
    def id
      attr_val('cda:act/cda:id/@root') || attr_val('cda:observation/cda:id/@root')
    end
    
    # Get the title of the criteria, provides a human readable description
    # @return [String] the title of this data criteria
    def title
      title = description
      title = "Occurrence #{('A'..'ZZ').to_a[@occurrence_key]}: #{title}" if @derived_from
      title
    end
    
    def description
      if (@entry.at_xpath('.//cda:title'))
        description = @entry.at_xpath('.//cda:title').inner_text
      else
        description = @entry.at_xpath('.//cda:localVariableName').inner_text
      end
      description
    end
    
    # Get a JS friendly constant name for this measure attribute
    def const_name
      components = title.gsub(/\W/,' ').split.collect {|word| word.strip.upcase }
      if @derived_from
        components << @@id.next
      end
      components.join '_'
    end
    
    def to_json
      {
        self.const_name => build_hash(
          self, 
          [:id,:title,:description,:code_list_id,:derived_from,:definition, :status, :negation])
      }
    end
    
    # Simple class to issue monotonically increasing integer identifiers
    class Counter
      def initialize
        @count = -1
      end

      def next
        @count+=1
      end
    end
    @@id = Counter.new
    @@occurrences = {}

  end
  
end