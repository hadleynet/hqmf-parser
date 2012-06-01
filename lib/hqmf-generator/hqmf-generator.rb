module HQMF2
  module Generator
  
    # Class to serialize HQMF::Document as HQMF V2 XML
    class ModelProcessor
      # Convert the supplied model instance to XML
      # @param [HQMF::Document] doc the model instance
      # @return [String] the serialized XML as a String
      def self.to_hqmf(doc)
        template_str = File.read(File.expand_path("../document.xml.erb", __FILE__))
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
    end
  
    # Utility class used to supply a binding to Erb. Contains utility functions used
    # by the erb templates that are used to generate the HQMF document.
    class ErbContext < OpenStruct
      
      def initialize(vars)
        super(vars)
      end
      
      # Get a binding that contains all the instance variables
      # @return [Binding]
      def get_binding
        binding
      end
      
      def xml_for_data_criteria(data_criteria)
        template_str = File.read(File.expand_path("../data_criteria.xml.erb", __FILE__))
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'criteria' => data_criteria}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def reference_element_name(data_criteria)
        case data_criteria.type
        when :encounters
          'encounterReference'
        when :procedures
          'procedureReference'
        when :medications
          'substanceAdministrationReference'
        else
          'observationReference'
        end
      end
      
      def criteria_element_name(data_criteria)
        case data_criteria.type
        when :encounters
          'encounterCriteria'
        when :procedures
          'procedureCriteria'
        when :medications
          'substanceAdministrationCriteria'
        else
          'observationCriteria'
        end
      end

      def section_name(data_criteria)
        case data_criteria.type
        when :conditions
          'Problems'
        when :encounters
          'Encounters'
        when :results
          'Results'
        when :procedures
          'Procedures'
        when :medications
          'Medications'
        when :characteristic
          'Demographics'
        when :derived
          'Derived'
        when :variable
          'Demographics'
        else
          raise "Unknown data criteria type [#{data_criteria.type}]"
        end
      end
    end
    
    # Simple class to issue monotonically increasing integer identifiers
    class Counter
      def initialize
        @count = 0
      end
      
      def new_id
        @count+=1
      end
    end
      
    # Singleton to keep a count of template identifiers
    class TemplateCounter < Counter
      include Singleton
    end

  end
end