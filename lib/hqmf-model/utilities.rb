
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
        elements.each do |element| 
          if (element.is_a? OpenStruct)
            array << element.marshal_dump 
          else
            array << element.to_json 
          end
        end
        array.compact!
        (array.empty?) ? nil : array
      end
    end
  end
end
