module HQMF1
  # Represents a data criteria specification
  class DataCriteria
  
    include HQMF1::Utilities
    
    attr_accessor :property, :type, :status, :standard_category, :qds_data_type, :description, :code_list_id, :derived_from
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(entry)
      @entry = entry
      
      config_file = File.expand_path('../data_criteria.json', __FILE__)
      config = JSON.parse(File.read(config_file))
      settings = config['defaults']
      template_id = attr_val('cda:act/cda:templateId/@root') || attr_val('cda:observation/cda:templateId/@root')
      
      # check to see if this is a derived data criteria.  These are used for multiple occurrences.
      derived_entry = @entry.at_xpath('./*/cda:sourceOf[@typeCode="DRIV"]')
      if derived_entry
        derived = derived_entry.at_xpath('cda:act/cda:id/@root') || derived_entry.at_xpath('cda:observation/cda:id/@root')
        @derived_from = derived.value
        @@occurrences[@derived_from] ||= Counter.new
        @occurrence_key = @@occurrences[@derived_from].next
      end
      
      if config[template_id]
        settings = settings.merge(config[template_id])
      else
        Kernel.warn "Unknown data criteria template identifier [#{template_id}]"
      end
      
      @type = settings['type'].intern
      # Get the code list OID of the criteria, used as an index to the code list database
      @code_list_id = attr_val(settings['code_list_xpath'])
      @status_xpath = settings['status_xpath']
      @property = settings['property'].intern
      @status = settings['status']
      @standard_category = settings['standard_category']
      @qds_data_type = settings['qds_data_type']
      @description = settings['description']
      
    end
    
    # Get the identifier of the criteria, used elsewhere within the document for referencing
    # @return [String] the identifier of this data criteria
    def id
      attr_val('cda:act/cda:id/@root') || attr_val('cda:observation/cda:id/@root')
    end
    
    # Get the title of the criteria, provides a human readable description
    # @return [String] the title of this data criteria
    def title
      if (@entry.at_xpath('.//cda:title'))
        title = @entry.at_xpath('.//cda:title').inner_text
      else
        title = @entry.at_xpath('.//cda:localVariableName').inner_text
      end
      title = "Occurrence #{('A'..'ZZ').to_a[@occurrence_key]}: #{title}" if @derived_from
      title
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
          [:id,:title,:code_list_id,:type,:status,:property,:standard_category,:qds_data_type,:description,:derived_from])
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