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
      # array.compact!
      # (array.empty?) ? nil : array
      array
    end
    
    def has_non_nil(json)
      # json.keys.reduce(false) do |has_non_nil, key|
      #   if (json[key].is_a? Array) 
      #     has_non_nil ||= !json[key].empty?
      #   else
      #     has_non_nil ||= !json[key].nil?
      #   end
      # end
      json
    end
    
    def clean_json(json)
      # json.reject!{|k,v| v.nil?}
      # json
      json
    end
    
  end
end  