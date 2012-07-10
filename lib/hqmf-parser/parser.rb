module HQMF
  class Parser
    
    HQMF_VERSION_1 = "1.0"
    HQMF_VERSION_2 = "2.0"
    
    def self.parse(hqmf_contents, version, codes = nil)
      
      
      case version
        when HQMF_VERSION_1
          Kernel.warn("Codes not passed in, cannot backfill properties like gender") unless codes
          HQMF::DocumentConverter.convert(HQMF1::Document.new(hqmf_contents).to_json, codes)
        when HQMF_VERSION_2
          HQMF2::Document.new(hqmf_contents).to_model
        else
          raise "Unsupported HQMF version specified: #{version}"
        end
      end
    
  end
end