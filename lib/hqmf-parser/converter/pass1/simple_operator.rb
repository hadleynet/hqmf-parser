module HQMF
  
  module Converter
  
    class SimpleOperator
      
      TEMPORAL = 'TEMPORAL'
      SUMMARY = 'SUMMARY'
      UNKNOWN = 'UNKNOWN'
      
      VALUE_FIELDS = {'SEV'=>'SEVERITY','117363000'=>'ORDINAL','285202004'=>'ENVIRONMENT','410666004'=>'REASON','446996006'=>'RADIATION_DOSAGE','306751006'=>'RADIATION_DURATION','183797002'=>'LENGTH_OF_STAY', '260753009'=>'SOURCE','363819003'=>'CUMULATIVE_MEDICTION_DURATION', 'SDLOC'=>'FACILITY_LOCATION'}
      

      attr_accessor :type, :value, :category, :field, :field_code

      def initialize(category, type, value, field = nil, field_code=nil)
        @category = category
        @type = type
        @value = value
        @field = field
        @field_code = field_code
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
        json[:field] = @field if @field
        json[:field_code] = @field_code if @field_code
        json[:value] = @value.to_json if @value
        json
      end
      
      def field_value_key
        key = VALUE_FIELDS[field_code]
        raise "unsupported field value: #{field_code}, #{field}" unless key
        key
      end

      def self.parse_value(value)
        return nil unless value
        return value if value.is_a? String
        if (value[:value])
          # values should be inclusive since we will be asking if it equals the value, ranther than being part of a range
          # if it's an offset we do not care that it is inclusive
          val = HQMF::Value.from_json(JSON.parse(value.to_json))
          val.inclusive=true
          val
        elsif (value[:high] or value[:low])
          HQMF::Range.from_json(JSON.parse(value.to_json))
        elsif (value[:type] == 'CD')
          HQMF::Coded.from_json(JSON.parse(value.to_json))
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