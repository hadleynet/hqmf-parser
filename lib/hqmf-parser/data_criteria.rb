module HQMF
  # Represents a data criteria specification
  class DataCriteria
  
    include HQMF::Utilities
    
    attr_reader :property, :type
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(entry)
      @entry = entry
      @code_list_xpath = 'cda:act/cda:sourceOf//cda:code/@code'
      template_id = attr_val('cda:act/cda:templateId/@root')
      case template_id
      when '2.16.840.1.113883.3.560.1.2'
        @type = :diagnosis
        @code_list_xpath = 'cda:act/cda:sourceOf/cda:observation/cda:value/@code'
        @status_xpath = 'cda:act/cda:sourceOf/cda:observation/cda:sourceOf/cda:observation/cda:value/@displayName'
      when '2.16.840.1.113883.3.560.1.3'
        @type = :procedure
        @status_xpath = 'cda:act/cda:sourceOf/cda:observation/cda:statusCode/@code'
      when '2.16.840.1.113883.3.560.1.4'
        @type = :encounter
      when '2.16.840.1.113883.3.560.1.5'
        @type = :result
        @status_xpath = 'cda:act/cda:sourceOf/cda:observation/cda:statusCode/@code'
      when '2.16.840.1.113883.3.560.1.6'
        @type = :procedure
      when '2.16.840.1.113883.3.560.1.8'
        @type = :medication
        @code_list_xpath = 'cda:act/cda:sourceOf/cda:supply/cda:participant/cda:roleParticipant/cda:playingMaterial/cda:code/@code'
      when '2.16.840.1.113883.3.560.1.13'
        @type = :medication
        @code_list_xpath = 'cda:act/cda:sourceOf/cda:substanceAdministration/cda:participant/cda:roleParticipant/cda:playingMaterial/cda:code/@code'
        @status_xpath = 'cda:act/cda:sourceOf/cda:substanceAdministration/cda:sourceOf/cda:observation/cda:value/@displayName'
      when '2.16.840.1.113883.3.560.1.14'
        @type = :medication
      when '2.16.840.1.113883.3.560.1.17'
        @type = :medication
        @code_list_xpath = 'cda:act/cda:sourceOf/cda:substanceAdministration/cda:participant/cda:roleParticipant/cda:playingMaterial/cda:code/@code'
      when '2.16.840.1.113883.3.560.1.25'
        @type = :characteristic
        @property = :birthtime
      when '2.16.840.1.113883.3.560.1.1001'
        @type = :characteristic
        @code_list_xpath = 'cda:act/cda:sourceOf/cda:observation/cda:value/@code'
        @property = :gender
      else
        raise "Unknown data criteria template identifier [#{template_id}]"
      end
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
    
    # Get the status of the criteria, e.g. active, completed, etc. Only present for
    # certain types like condition, diagnosis, procedure, etc.
    # @return [String] the status of this data criteria
    def status
      if @status_path
        attr_val(@status_xpath)
      else
        nil
      end
    end
    
    # Get a JS friendly constant name for this measure attribute
    def const_name
      components = title.gsub(/\W/,' ').split.collect {|word| word.strip.upcase }
      components.join '_'
    end
    
    def to_json
      json = {}
      
      json[self.const_name] = {
        title: self.title,
        code_list_oid: self.code_list_id,
        type: self.type,
        status: self.status,
        property: self.property,
        codes: {}
      }
      
      json
      
    end

  end
  
end