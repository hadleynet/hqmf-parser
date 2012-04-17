
module HQMF
  module JSON
    module Utilities
      def build_hash(source, elements)
        hash = {}
        elements.each do |element|
          value = source.send(element)
          hash[element] = value if value
        end
        hash
      end

      def json_array(elements) 
        array = []
        elements.each {|element| array << element.to_json }
        array.compact!
        (array.empty?) ? nil : array
      end
    end
  end
end
