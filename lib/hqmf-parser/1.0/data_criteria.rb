module HQMF1
  # Represents a data criteria specification
  class DataCriteria
  
    include HQMF1::Utilities
    
    attr_reader :property, :type, :status, :standard_category, :qds_data_type
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(entry)
      @entry = entry
      
      config_file = File.expand_path('../data_criteria.json', __FILE__)
      config = JSON.parse(File.read(config_file))
      settings = config['defaults']
      template_id = attr_val('cda:act/cda:templateId/@root')
      if config[template_id]
        settings = settings.merge(config[template_id])
      else
        Kernel.warn "Unknown data criteria template identifier [#{template_id}]"
      end
      
      @type = settings['type'].intern
      @code_list_xpath = settings['code_list_xpath']
      @status_xpath = settings['status_xpath']
      @property = settings['property'].intern
      @status = settings['status']
      @standard_category = settings['standard_category']
      @qds_data_type = settings['qds_data_type']
    end
    
    # Get the identifier of the criteria, used elsewhere within the document for referencing
    # @return [String] the identifier of this data criteria
    def id
      attr_val('cda:act/cda:id/@root')
    end
    
    # Get the title of the criteria, provides a human readable description
    # @return [String] the title of this data criteria
    def title
      @entry.at_xpath('.//cda:title').inner_text
    end
    
    # Get the code list OID of the criteria, used as an index to the code list database
    # @return [String] the code list identifier of this data criteria
    def code_list_id
      attr_val(@code_list_xpath)
    end
    
    # Get a JS friendly constant name for this measure attribute
    def const_name
      components = title.gsub(/\W/,' ').split.collect {|word| word.strip.upcase }
      components.join '_'
    end
    
    def to_json
      {
        self.const_name => build_hash(
          self, 
          [:id,:title,:code_list_id,:type,:status,:property,:standard_category,:qds_data_type])
      }
    end

  end
  
end