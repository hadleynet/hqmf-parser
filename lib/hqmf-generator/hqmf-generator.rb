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
      
      def xml_for_value(value, element_name='value', include_type=true)
        template_path = File.expand_path(File.join('..', 'value.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'value' => value, 'name' => element_name, 'include_type' => include_type}
        context = ErbContext.new(params)
        template.result(context.get_binding)        
      end
      
      def xml_for_code(criteria, element_name='code', include_type=true)
        template_path = File.expand_path(File.join('..', 'code.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'criteria' => criteria, 'name' => element_name, 'include_type' => include_type}
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
      
      def xml_for_effective_time(data_criteria)
        xml = ''
        if data_criteria.effective_time
            template_path = File.expand_path(File.join('..', 'effective_time.xml.erb'), __FILE__)
            template_str = File.read(template_path)
            template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
            params = {'doc' => doc, 'effective_time' => data_criteria.effective_time}
            context = ErbContext.new(params)
            xml = template.result(context.get_binding)
        end
        xml
      end
      
      def xml_for_subsets(data_criteria)
        subsets_xml = []
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
      
      def xml_for_precondition(precondition)
        template_path = File.expand_path(File.join('..', 'precondition.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'precondition' => precondition}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def xml_for_data_criteria(data_criteria)
        template_path = File.expand_path(File.join('..', data_criteria_template_name(data_criteria)), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'criteria' => data_criteria}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def xml_for_population_criteria(population_criteria)
        template_path = File.expand_path(File.join('..', 'population_criteria.xml.erb'), __FILE__)
        template_str = File.read(template_path)
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'criteria' => population_criteria}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def xml_for_temporal_references(criteria)
        refs = []
        if criteria.temporal_references
          refs = criteria.temporal_references.collect do |reference|
            template_path = File.expand_path(File.join('..', 'temporal_relationship.xml.erb'), __FILE__)
            template_str = File.read(template_path)
            template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
            params = {'doc' => doc, 'relationship' => reference}
            context = ErbContext.new(params)
            template.result(context.get_binding)
          end
        end
        refs.join
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
        when :birthtime
          '21112-8'
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
      
      def oid_for_characteristic(characteristic)
        case characteristic
        when :birthtime
          '2.16.840.1.113883.6.1'
        else
          '2.16.840.1.113883.6.96'
        end
      end
      
      def data_criteria_template_name(data_criteria)
        case data_criteria.type
        when :conditions, :activeDiagnoses 
          'condition_criteria.xml.erb'
        when :encounters 
          'encounter_criteria.xml.erb'
        when :procedures
          'procedure_criteria.xml.erb'
        when :medications, :allMedications
          'substance_criteria.xml.erb'
        when :medication_supply
          'supply_criteria.xml.erb'
        when :characteristic
          'characteristic_criteria.xml.erb'
        when :variable
          'variable_criteria.xml.erb'
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
        when :results, :laboratory_tests
          'Results'
        when :procedures
          'Procedures'
        when :medications
          'Medications'
        when :medication_supply
          'RX'
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
        type = data_criteria ? data_criteria.type : :observation
        case type
        when :encounters
          'encounter'
        when :procedures
          'procedure'
        when :medications, :allMedications
          'substanceAdministration'
        when :medication_supply
          'supply'
        else
          'observation'
        end
      end
      
      def population_element_prefix(population_criteria_code)
        case population_criteria_code
        when 'IPP'
          'patientPopulation'
        when 'DENOM'
          'denominator'
        when 'NUMER'
          'numerator'
        when 'DENEXCEP'
          'denominatorException'
        else
          raise "Unknown population criteria type #{population_criteria_code}"
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