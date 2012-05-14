require_relative '../../../test_helper'
module HQMFModel

  class NQF0002Test  < Test::Unit::TestCase
    def setup
      path = File.expand_path("../../../../fixtures/1.0/0002/0002.xml", __FILE__)
      @hqmf_contents = File.open(path).read
    end
  
    def test_to_json_0002
      hqmf = HQMF::Parser.parse(@hqmf_contents, HQMF::Parser::HQMF_VERSION_1)
      
      json = hqmf.to_json
      
      json[:id].must_equal "0002"
      json[:title].must_equal "Appropriate Testing for Children with Pharyngitis"
      refute_nil json[:description]
            
      all_criteria = json[:data_criteria]
      refute_nil all_criteria
      all_criteria.length.must_equal 23
      all_criteria.length.must_equal hqmf.all_data_criteria.length

      [:PatientCharacteristicBirthDate, :EncounterEncounterAmbulatoryIncludingPediatrics, :LaboratoryTestPerformedGroupAStreptococcusTest,
       :DiagnosisActivePharyngitis, :MedicationActivePharyngitisAntibiotics, :MedicationDispensedPharyngitisAntibiotics,
       :MedicationOrderPharyngitisAntibiotics].each do |data_criteria_key|
         assert all_criteria.keys.grep(/#{data_criteria_key.to_s}/).size > 0, "Could not find any data criteria for #{data_criteria_key}"
      end
      
      expected_dc = {}
      expected_dc[:PatientCharacteristicBirthDate] = []
      expected_dc[:EncounterEncounterAmbulatoryIncludingPediatrics] = []
      expected_dc[:LaboratoryTestPerformedGroupAStreptococcusTest] = []
      expected_dc[:DiagnosisActivePharyngitis] = []
      expected_dc[:MedicationActivePharyngitisAntibiotics] = []
      expected_dc[:MedicationDispensedPharyngitisAntibiotics] = []
      expected_dc[:MedicationOrderPharyngitisAntibiotics] = []
      
      expected_dc[:PatientCharacteristicBirthDate] << {:title=>"birth date",
         :description=>"Patient Characteristic: birth date",
         :standard_category=>"individual_characteristic",
         :code_list_id=>"2.16.840.1.113883.3.560.100.4",
         :property=>:age,
         :type=>:characteristic}
      expected_dc[:EncounterEncounterAmbulatoryIncludingPediatrics] << {:title=>"Encounter ambulatory including pediatrics",
         :description=>"Encounter: Encounter ambulatory including pediatrics",
         :standard_category=>"encounter",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.231",
         :type=>:encounters,
         :effective_time=>{:type=>"IVL_TS", :low=>{:type=>"TS", :value=>"20100101"}, :high=>{:type=>"TS", :value=>"20101231"}, :width=>{:type=>"PQ", :unit=>"a", :value=>"1"}}}
      expected_dc[:LaboratoryTestPerformedGroupAStreptococcusTest] << {:title=>"Group A Streptococcus Test",
         :description=>"Laboratory Test, Performed: Group A Streptococcus Test",
         :standard_category=>"laboratory_test",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.250",
         :type=>:laboratoryTests,
         :status=>"performed"}
      expected_dc[:DiagnosisActivePharyngitis] << {:title=>"pharyngitis",
         :description=>"Diagnosis, Active: pharyngitis",
         :standard_category=>"diagnosis_condition_problem",
         :qds_data_type=>"diagnosis_active",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.369",
         :type=>:activeDiagnoses,
         :status=>"active"}
      expected_dc[:MedicationActivePharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Active: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_active",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"active"}
      expected_dc[:MedicationDispensedPharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Dispensed: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_dispensed",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"dispensed"}
      expected_dc[:MedicationOrderPharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Order: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_order",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"ordered"}
      expected_dc[:MedicationDispensedPharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Dispensed: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_dispensed",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"dispensed",
         :value=>{:type=>"IVL_PQ",:high=>{:type=>"PQ", :unit=>"d", :value=>"30", inclusive?:true}},:effective_time=>{:type=>"IVL_TS"}}
      expected_dc[:MedicationOrderPharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Order: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_order",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"ordered",
         :value=>{:type=>"IVL_PQ",:high=>{:type=>"PQ", :unit=>"d", :value=>"30", inclusive?:true}},
         :effective_time=>{:type=>"IVL_TS"}}
      expected_dc[:MedicationActivePharyngitisAntibiotics] << {:title=>"pharyngitis antibiotics",
         :description=>"Medication, Active: pharyngitis antibiotics",
         :standard_category=>"medication",
         :qds_data_type=>"medication_active",
         :code_list_id=>"2.16.840.1.113883.3.464.0001.373",
         :type=>:allMedications,
         :status=>"active",
         :value=>{:type=>"IVL_PQ",:high=>{:type=>"PQ", :unit=>"d", :value=>"30", inclusive?:true}}, :effective_time=>{:type=>"IVL_TS"}}
      expected_dc[:PatientCharacteristicBirthDate] << {:title=>"birth date",
         :description=>"Patient Characteristic: birth date",
         :standard_category=>"individual_characteristic",
         :code_list_id=>"2.16.840.1.113883.3.560.100.4",
         :property=>:age,
         :type=>:characteristic,
         :value=>{:type=>"IVL_PQ",:low=>{:type=>"PQ", :unit=>"a", :value=>"2", inclusive?:true}},
         :effective_time=>{:type=>"IVL_TS", :high=>{:type=>"TS", :value=>"20100101"}}}
      expected_dc[:PatientCharacteristicBirthDate] << {:title=>"birth date",
         :description=>"Patient Characteristic: birth date",
         :standard_category=>"individual_characteristic",
         :code_list_id=>"2.16.840.1.113883.3.560.100.4",
         :property=>:age,
         :type=>:characteristic,
         :value=>{:type=>"IVL_PQ",:high=>{:type=>"PQ", :unit=>"a", :value=>"17", inclusive?:true}},
         :effective_time=>{:type=>"IVL_TS", :high=>{:type=>"TS", :value=>"20100101"}}}
      
      
      all_criteria.keys.each do |key|
        orig_key = key
        key = key.to_s.gsub(/_precondition_\d+/, '').to_sym
        found_matching = false
        expected_dc[key].each do |expected|
          data_criteria = all_criteria[orig_key]
          diff = expected.diff_hash(data_criteria)
          found_matching ||= diff.empty?
        end
        assert found_matching, "could not find matching expected criteria for #{orig_key}"
      end
      
      
      logic = json[:population_criteria]
      refute_nil logic
      [:NUMER, :DENOM, :IPP].each do |logic_key|
        refute_nil logic[logic_key]
      end
      
      population_criteria = logic[:NUMER]
      population_criteria[:conjunction?].must_equal true
      population_criteria[:preconditions].size.must_equal 2

      numerator = 
      {conjunction?:true,
       :preconditions=>[
         { :preconditions=>[{:reference=>"LaboratoryTestPerformedGroupAStreptococcusTest",
             :preconditions=>
              [{:preconditions=>[{:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics", :conjunction_code=>"encountersReference"}],
                :conjunction_code=>"allTrue"},
               {:preconditions=>
                 [{:reference=>"MedicationDispensedPharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"},
                  {:reference=>"MedicationOrderPharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"},
                  {:reference=>"MedicationActivePharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"}],
                :conjunction_code=>"atLeastOneTrue"}
              ],
             :conjunction_code=>"laboratoryTestsReference"}],
           :conjunction_code=>"allTrue"
         },
         {:preconditions=>[
           { :reference=>"LaboratoryTestPerformedGroupAStreptococcusTest",
             :preconditions=>
              [ 
                {:preconditions=>[{:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics", :conjunction_code=>"encountersReference"}],
                 :conjunction_code=>"allTrue"},
                {:preconditions=>[
                  {:reference=>"MedicationDispensedPharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"},
                  {:reference=>"MedicationOrderPharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"},
                  {:reference=>"MedicationActivePharyngitisAntibiotics", :conjunction_code=>"allMedicationsReference"}],
                 :conjunction_code=>"atLeastOneTrue"
                }
              ],
             :conjunction_code=>"laboratoryTestsReference"
           }],
          :conjunction_code=>"allTrue"
         }
      ]
      }
      
      diff = numerator.diff_hash(population_criteria,true)
      assert diff.empty?, "differences: #{diff.to_json}"
      
      population_criteria = logic[:IPP]
      
      ipp = 
      {
        conjunction?:true,
        :preconditions=>[
          {:preconditions=>[{:reference=>"PatientCharacteristicBirthDate",:conjunction_code=>"characteristicReference"}],:conjunction_code=>"allTrue"},
          {:preconditions=>[{:reference=>"PatientCharacteristicBirthDate",:conjunction_code=>"characteristicReference"}],:conjunction_code=>"allTrue"}
        ]
      }
      
      diff = ipp.diff_hash(population_criteria,true)
      assert diff.empty?, "differences: #{diff.to_json}"

      population_criteria = logic[:DENOM]
      
      denom = 
      {
        conjunction?:true,
        :preconditions=>
          [
            {:preconditions=>[{:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics",:conjunction_code=>"encountersReference"}], :conjunction_code=>"allTrue"},
            {:preconditions=>[{:reference=>"DiagnosisActivePharyngitis",
               :preconditions=>[{:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics",
                                 :conjunction_code=>"encountersReference"}], :conjunction_code=>"activeDiagnosesReference"}],
             :conjunction_code=>"allTrue"},
            {:preconditions=>
              [
                {:preconditions=>[{:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics",:conjunction_code=>"encountersReference"}],
                 :conjunction_code=>"atLeastOneTrue"},
                {:preconditions=>
                  [{:reference=>"MedicationDispensedPharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"},
                   {:reference=>"MedicationOrderPharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"},
                   {:reference=>"MedicationActivePharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"}],
                 :conjunction_code=>"atLeastOneTrue"}
              ],
              :conjunction_code=>"allTrue"},
            {:preconditions=>
              [
                {:preconditions=>
                  [{:reference=>"MedicationDispensedPharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"},
                   {:reference=>"MedicationOrderPharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"},
                   {:reference=>"MedicationActivePharyngitisAntibiotics",:conjunction_code=>"allMedicationsReference"}],
                 :conjunction_code=>"atLeastOneTrue"},
                {:reference=>"EncounterEncounterAmbulatoryIncludingPediatrics",:conjunction_code=>"encountersReference"}
              ],
              :conjunction_code=>"allTrue",
              :negation=>true
            }
          ]
      }
      diff = denom.diff_hash(population_criteria,true)
      assert diff.empty?, "differences: #{diff.to_json}"
      
    end
    
    def test_json_round_trip
      hqmf = HQMF::Parser.parse(@hqmf_contents, HQMF::Parser::HQMF_VERSION_1)
      
      json = hqmf.to_json
      
      model = HQMF::Document.from_json(JSON.parse(json.to_json))
      
      json2 = model.to_json
      
      diff = json.diff_hash(json2)
      assert diff.empty?, "differences: #{diff.to_json}"
    
    end

    def test_finders
      model = HQMF::Parser.parse(@hqmf_contents, HQMF::Parser::HQMF_VERSION_1)
      
      model.all_data_criteria.size.must_equal 23
      
      model.all_data_criteria.map(&:id).each do |key|
        
        refute_nil model.data_criteria(key)
      end

      model.all_population_criteria.size.must_equal 3
      
      ["NUMER", "DENOM", "IPP"].each do |key|
        refute_nil model.population_criteria(key)
      end
    
    end
    
  end
end
