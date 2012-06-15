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
      
      def xml_for_reference_id(id)
        reference = HQMF::Reference.new(id)
        xml_for_reference(reference)
      end
      
      def xml_for_reference(reference)
        template_path = File.expand_path(File.join('..', 'reference.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'reference' => reference}
        context = ErbContext.new(params)
        template.result(context.get_binding)        
      end
      
      def xml_for_value(value, element_name='value')
        template_path = File.expand_path(File.join('..', 'value.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'value' => value, 'name' => element_name}
        context = ErbContext.new(params)
        template.result(context.get_binding)        
      end
      
      def xml_for_code(criteria, element_name='code')
        template_path = File.expand_path(File.join('..', 'code.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'criteria' => criteria, 'name' => element_name}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
           
      def xml_for_derivation(data_criteria)
        xml = ''
        if data_criteria.derivation_operator
            template_path = File.expand_path(File.join('..', 'derivation.xml.erb'), __FILE__)
            template_str = File.read(template_path)
            template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
            params = {'doc' => doc, 'criteria' => data_criteria}
            context = ErbContext.new(params)
            xml = template.result(context.get_binding)
        end
        xml
      end
      
      def xml_for_subsets(data_criteria)
        if data_criteria.subset_operators
          subsets_xml = data_criteria.subset_operators.collect do |operator|
            template_path = File.expand_path(File.join('..', 'subset.xml.erb'), __FILE__)
            template_str = File.read(template_path)
            template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
            params = {'doc' => doc, 'subset' => operator, 'criteria' => data_criteria}
            context = ErbContext.new(params)
            template.result(context.get_binding)
          end
        end
        subsets_xml.join()
      end
      
      def xml_for_data_criteria(data_criteria)
        template_path = File.expand_path(File.join('..', data_criteria_template_name(data_criteria)), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'criteria' => data_criteria}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def xml_for_temporal_reference(reference)
        template_path = File.expand_path(File.join('..', 'temporal_relationship.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'relationship' => reference}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def oid_for_name(code_system_name)
        HealthDataStandards::Util::CodeSystemHelper.oid_for_code_system(code_system_name)
      end
      
      def reference_element_name(id)
        referenced_criteria = doc.data_criteria(id)
        element_name_prefix(referenced_criteria)
      end
      
      def code_for_characteristic(characteristic)
        case characteristic
        when :age
          '424144002'
        when :gender
          '263495000'
        when :languages
          '102902016'
        when :maritalStatus
          '125680007'
        when :race
          '103579009'
        else
          raise "Unknown demographic code [#{characteristic}]"
        end
      end
      
      def data_criteria_template_name(data_criteria)
        case data_criteria.type
        when :encounters
          'encounter_criteria.xml.erb'
        when :procedures
          'procedure_criteria.xml.erb'
        when :medications
          'substance_criteria.xml.erb'
        else
          'observation_criteria.xml.erb'
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

      def element_name_prefix(data_criteria)
        case data_criteria.type
        when :encounters
          'encounter'
        when :procedures
          'procedure'
        when :medications
          'substanceAdministration'
        else
          'observation'
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