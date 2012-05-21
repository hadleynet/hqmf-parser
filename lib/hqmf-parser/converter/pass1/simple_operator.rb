module HQMF
  
  module Converter
  
    class SimpleOperator
      
      TEMPORAL = 'TEMPORAL'
      SUMMARY = 'SUMMARY'
      UNKNOWN = 'UNKNOWN'

      attr_accessor :type, :value, :category, :field

      def initialize(category, type, value, field = nil)
        @category = category
        @type = type
        @value = value
        @field = field
      end
      
      def temporal?
        category == TEMPORAL
      end
      def summary?
        category == SUMMARY
      end
      
      def to_json
        json = {}
        json[:category] = @category if @category
        json[:type] = @type if @type
        json[:value] = @value.to_json if @value
        json
      end

      def self.parse_value(value)
        if (value[:value])
          # values should be inclusive since we will be asking if it equals the value, ranther than being part of a range
          # if it's an offset we do not care that it is inclusive
          HQMF::Value.from_json(JSON.parse(value.to_json).merge({"inclusive?"=>true}))
        elsif (value[:high] or value[:low])
          HQMF::Range.from_json(JSON.parse(value.to_json))
        end
      end
      
      def self.find_category(type)
        return TEMPORAL if HQMF::TemporalReference::TYPES.include? type
        return SUMMARY if HQMF::SubsetOperator::TYPES.include? type
        return UNKNOWN
      end



    end
    
    
    
  end
  


  
end