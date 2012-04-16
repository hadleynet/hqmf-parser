module HQMF
  class Parser
    
    HQMF_VERSION_1 = "1.0"
    HQMF_VERSION_2 = "2.0"
    
    def self.parse(hqmf_contents, version)
      
      
      case version
        when HQMF_VERSION_1
          HQMF1::Document.new(hqmf_contents)
        when HQMF_VERSION_2
          HQMF2::Document.new(hqmf_contents)
        else
          raise "Unsupported HQMF version specified: #{version}"
        end
      end
    
  end
end