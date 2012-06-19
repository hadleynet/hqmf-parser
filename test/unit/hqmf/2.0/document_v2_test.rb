require_relative '../../../test_helper'

  class DocumentV2Test < Test::Unit::TestCase
    def setup
      @hqmf_contents = File.open("test/fixtures/2.0/NQF59New.xml").read
      @doc = HQMF2::Document.new(@hqmf_contents)
      @model = @doc.to_model
    end
  
    def test_parse
      doc = HQMF2::Document.parse(@hqmf_contents)
      assert_equal 'QualityMeasureDocument', doc.root.name
      assert_equal 'urn:hl7-org:v3', doc.root.namespace.href 
    end
  
    def test_metadata
      assert_equal 'foo', @doc.id
      assert_equal "Sample Quality Measure Document", @doc.title
      assert_equal "This is the measure description.", @doc.description
      assert @doc.measure_period
      assert_equal '20110101', @doc.measure_period.low.value
      assert_equal '20111231', @doc.measure_period.high.value
    end

    def test_model_metadata
      assert_equal 'foo', @model.id
      assert_equal "Sample Quality Measure Document", @model.title
      assert_equal "This is the measure description.", @model.description
      assert @model.measure_period
      assert_equal '20110101', @model.measure_period.low.value
      assert_equal '20111231', @model.measure_period.high.value
    end
  
    def test_population_criteria
      all_population_criteria = @doc.all_population_criteria
      assert_equal 6, all_population_criteria.length
    
      codes = all_population_criteria.collect {|p| p.id}
      %w(IPP DENOM NUMER DENEXCEP).each do |c|
        assert codes.include?(c)
      end

      ipp = @doc.population_criteria('IPP')
      assert ipp.conjunction?
      assert_equal 'allTrue', ipp.conjunction_code
      assert_equal 1, ipp.preconditions.length
      assert_equal false, ipp.preconditions[0].conjunction?
      assert_equal 'ageBetween17and64', ipp.preconditions[0].reference.id

      den = @doc.population_criteria('DENOM')
      assert_equal 1, den.preconditions.length
      assert den.preconditions[0].conjunction?
      assert_equal 'atLeastOneTrue', den.preconditions[0].conjunction_code
      assert_equal 5, den.preconditions[0].preconditions.length
      assert den.preconditions[0].preconditions[0].conjunction?
      assert_equal 'allTrue', den.preconditions[0].preconditions[0].conjunction_code
      assert_equal 2, den.preconditions[0].preconditions[0].preconditions.length
      assert_equal false, den.preconditions[0].preconditions[0].preconditions[0].conjunction?
      assert_equal 'HasDiabetes', den.preconditions[0].preconditions[0].preconditions[0].reference.id
    
      num = @doc.population_criteria('NUMER')
      assert_equal 1, num.preconditions.length
      assert_equal false, num.preconditions[0].conjunction?
      assert_equal 'HbA1C', num.preconditions[0].reference.id

      ipp = @doc.population_criteria('DENEXCEP')
      assert ipp.conjunction?
      assert_equal 'atLeastOneTrue', ipp.conjunction_code
      assert_equal 3, ipp.preconditions.length
    end
  
    def test_model_population_criteria
      all_population_criteria = @model.all_population_criteria
      assert_equal 6, all_population_criteria.length
    
      codes = all_population_criteria.collect {|p| p.id}
      %w(IPP DENOM NUMER DENEXCEP).each do |c|
        assert codes.include?(c)
      end

      ipp = @model.population_criteria('IPP')
      assert ipp.conjunction?
      assert_equal 'allTrue', ipp.conjunction_code
      assert_equal 1, ipp.preconditions.length
      assert_equal false, ipp.preconditions[0].conjunction?
      assert_equal 'ageBetween17and64', ipp.preconditions[0].reference.id

      den = @model.population_criteria('DENOM')
      assert_equal 1, den.preconditions.length
      assert den.preconditions[0].conjunction?
      assert_equal 'atLeastOneTrue', den.preconditions[0].conjunction_code
      assert_equal 5, den.preconditions[0].preconditions.length
      assert den.preconditions[0].preconditions[0].conjunction?
      assert_equal 'allTrue', den.preconditions[0].preconditions[0].conjunction_code
      assert_equal 2, den.preconditions[0].preconditions[0].preconditions.length
      assert_equal false, den.preconditions[0].preconditions[0].preconditions[0].conjunction?
      assert_equal 'HasDiabetes', den.preconditions[0].preconditions[0].preconditions[0].reference.id
    
      num = @model.population_criteria('NUMER')
      assert_equal 1, num.preconditions.length
      assert_equal false, num.preconditions[0].conjunction?
      assert_equal 'HbA1C', num.preconditions[0].reference.id

      ipp = @model.population_criteria('DENEXCEP')
      assert ipp.conjunction?
      assert_equal 'atLeastOneTrue', ipp.conjunction_code
      assert_equal 3, ipp.preconditions.length
    end
  
    def test_data_criteria
      data_criteria = @doc.all_data_criteria
      assert_equal 30, data_criteria.length
    
      criteria = @doc.data_criteria('EndDate')
      assert criteria.to_xml.include?('extension="EndDate"')
      assert_equal :variable, criteria.type
      assert_equal 'EndDate', criteria.title
      assert_equal HQMF2::Value, criteria.value.class
      assert_equal '20101231', criteria.value.value
      assert_equal 'TS', criteria.value.type

      criteria = @doc.data_criteria('ageBetween17and64')
      assert_equal :characteristic, criteria.type
      assert_equal 'ageBetween17and64', criteria.title
      assert_equal :age, criteria.property
      assert_equal HQMF2::Range, criteria.value.class
      assert_equal 'IVL_PQ', criteria.value.type
      assert_equal '17', criteria.value.low.value
      assert_equal 'a', criteria.value.low.unit
      assert_equal false, criteria.value.low.derived?
      assert_equal true, criteria.value.low.inclusive?
      assert_equal '64', criteria.value.high.value
      assert_equal 'a', criteria.value.high.unit
      assert_equal false, criteria.value.high.derived?
      assert_equal true, criteria.value.high.inclusive?

      criteria = @doc.data_criteria('genderMale')
      assert_equal :characteristic, criteria.type
      assert_equal 'genderMale', criteria.title
      assert_equal :gender, criteria.property
      assert_equal HQMF2::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'M', criteria.value.code
      assert_equal '2.16.840.1.113883.5.1', criteria.value.system

      criteria = @doc.data_criteria('DummyLanguage_Arabic')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyLanguage_Arabic', criteria.title
      assert_equal :languages, criteria.property
      assert_equal HQMF2::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'ar', criteria.value.code
      assert_equal '1.0.639.1', criteria.value.system

      criteria = @doc.data_criteria('DummyMaritalStatus_Divorced')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyMaritalStatus_Divorced', criteria.title
      assert_equal :maritalStatus, criteria.property
      assert_equal HQMF2::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'D', criteria.value.code
      assert_equal '2.16.840.1.113883.5.2', criteria.value.system

      criteria = @doc.data_criteria('DummyRace_Latin_American')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyRace_Latin_American', criteria.title
      assert_equal :race, criteria.property
      assert_equal HQMF2::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal '2178-2', criteria.value.code
      assert_equal '2.16.840.1.113883.6.238', criteria.value.system

      criteria = @doc.data_criteria('DummyProcedureAfterHasDiabetes')
      assert_equal :procedures, criteria.type
      assert criteria.inline_code_list
      assert_equal '127355002', criteria.inline_code_list['SNOMED-CT'][0]
      assert criteria.effective_time
      assert_equal '20100101', criteria.effective_time.low.value
      assert_equal '20111231', criteria.effective_time.high.value
      assert_equal 'completed', criteria.status
      assert_equal 1, criteria.temporal_references.length
      assert_equal 'SAS', criteria.temporal_references[0].type
      assert_equal 'HasDiabetes', criteria.temporal_references[0].reference.id
      assert_equal '-1', criteria.temporal_references[0].offset.value
      assert_equal 'a', criteria.temporal_references[0].offset.unit

      criteria = @doc.data_criteria('EDorInpatientEncounter')
      assert_equal :encounters, criteria.type
      assert_equal 'EDorInpatientEncounter', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.42', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.low
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate.add(new PQ(-2,"a"))', criteria.effective_time.high.expression
      assert_equal 0, criteria.temporal_references.length

      criteria = @doc.data_criteria('HasGestationalDiabetes')
      assert_equal :conditions, criteria.type
      assert_equal 'HasGestationalDiabetes', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.67', criteria.code_list_id
      assert criteria.effective_time
      assert criteria.effective_time.low
      assert_equal true, criteria.effective_time.low.derived?
      assert_equal 'StartDate', criteria.effective_time.low.expression
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate', criteria.effective_time.high.expression

      criteria = @doc.data_criteria('HbA1C')
      assert_equal :results, criteria.type
      assert_equal 'HbA1C', criteria.title
      assert_equal 1, criteria.subset_operators.length
      assert_equal 'RECENT', criteria.subset_operators[0].type
      assert_equal '2.16.840.1.113883.3.464.1.72', criteria.code_list_id
      assert_equal 'completed', criteria.status
      assert_equal nil, criteria.effective_time
      assert_equal HQMF2::Range, criteria.value.class
      assert_equal nil, criteria.value.high
      assert criteria.value.low
      assert_equal '9', criteria.value.low.value
      assert_equal '%', criteria.value.low.unit

      criteria = @doc.data_criteria('DiabetesMedAdministered')
      assert_equal :medications, criteria.type
      assert_equal 'DiabetesMedAdministered', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.94', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.high
      assert criteria.effective_time.low
      assert_equal true, criteria.effective_time.low.derived?
      assert_equal 'StartDate.add(new PQ(-2,"a"))', criteria.effective_time.low.expression

      criteria = @doc.data_criteria('DiabetesMedSupplied')
      assert_equal :medication_supply, criteria.type
      assert_equal 'DiabetesMedSupplied', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.94', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.low
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate.add(new PQ(-2,"a"))', criteria.effective_time.high.expression
      
      criteria = @doc.data_criteria('anyDiabetes')
      assert_equal :derived, criteria.type
      assert_equal 2, criteria.children_criteria.length
      assert criteria.children_criteria.include? 'HasDiabetes'
      assert criteria.children_criteria.include? 'HasGestationalDiabetes'

      assert_nil @doc.data_criteria('foo')
    end
    
    def test_model_data_criteria
      data_criteria = @model.all_data_criteria
      assert_equal 30, data_criteria.length
    
      criteria = @model.data_criteria('EndDate')
      assert_equal :variable, criteria.type
      assert_equal 'EndDate', criteria.title
      assert_equal HQMF::Value, criteria.value.class
      assert_equal '20101231', criteria.value.value
      assert_equal 'TS', criteria.value.type

      criteria = @model.data_criteria('ageBetween17and64')
      assert_equal :characteristic, criteria.type
      assert_equal 'ageBetween17and64', criteria.title
      assert_equal :age, criteria.property
      assert_equal HQMF::Range, criteria.value.class
      assert_equal 'IVL_PQ', criteria.value.type
      assert_equal '17', criteria.value.low.value
      assert_equal 'a', criteria.value.low.unit
      assert_equal false, criteria.value.low.derived?
      assert_equal true, criteria.value.low.inclusive?
      assert_equal '64', criteria.value.high.value
      assert_equal 'a', criteria.value.high.unit
      assert_equal false, criteria.value.high.derived?
      assert_equal true, criteria.value.high.inclusive?

      criteria = @model.data_criteria('genderMale')
      assert_equal :characteristic, criteria.type
      assert_equal 'genderMale', criteria.title
      assert_equal :gender, criteria.property
      assert_equal HQMF::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'M', criteria.value.code
      assert_equal '2.16.840.1.113883.5.1', criteria.value.system

      criteria = @model.data_criteria('DummyLanguage_Arabic')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyLanguage_Arabic', criteria.title
      assert_equal :languages, criteria.property
      assert_equal HQMF::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'ar', criteria.value.code
      assert_equal '1.0.639.1', criteria.value.system

      criteria = @model.data_criteria('DummyMaritalStatus_Divorced')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyMaritalStatus_Divorced', criteria.title
      assert_equal :maritalStatus, criteria.property
      assert_equal HQMF::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal 'D', criteria.value.code
      assert_equal '2.16.840.1.113883.5.2', criteria.value.system

      criteria = @model.data_criteria('DummyRace_Latin_American')
      assert_equal :characteristic, criteria.type
      assert_equal 'DummyRace_Latin_American', criteria.title
      assert_equal :race, criteria.property
      assert_equal HQMF::Coded, criteria.value.class
      assert_equal 'CD', criteria.value.type
      assert_equal '2178-2', criteria.value.code
      assert_equal '2.16.840.1.113883.6.238', criteria.value.system

      criteria = @model.data_criteria('DummyProcedureAfterHasDiabetes')
      assert_equal :procedures, criteria.type
      assert criteria.inline_code_list
      assert_equal '127355002', criteria.inline_code_list['SNOMED-CT'][0]
      assert criteria.effective_time
      assert_equal '20100101', criteria.effective_time.low.value
      assert_equal '20111231', criteria.effective_time.high.value
      assert_equal 'completed', criteria.status
      assert_equal 1, criteria.temporal_references.length
      assert_equal 'SAS', criteria.temporal_references[0].type
      assert_equal 'HasDiabetes', criteria.temporal_references[0].reference.id
      assert_equal '-1', criteria.temporal_references[0].offset.value
      assert_equal 'a', criteria.temporal_references[0].offset.unit

      criteria = @model.data_criteria('EDorInpatientEncounter')
      assert_equal :encounters, criteria.type
      assert_equal 'EDorInpatientEncounter', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.42', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.low
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate.add(new PQ(-2,"a"))', criteria.effective_time.high.expression
      assert_equal 0, criteria.temporal_references.length

      criteria = @model.data_criteria('HasGestationalDiabetes')
      assert_equal :conditions, criteria.type
      assert_equal 'HasGestationalDiabetes', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.67', criteria.code_list_id
      assert criteria.effective_time
      assert criteria.effective_time.low
      assert_equal true, criteria.effective_time.low.derived?
      assert_equal 'StartDate', criteria.effective_time.low.expression
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate', criteria.effective_time.high.expression

      criteria = @model.data_criteria('HbA1C')
      assert_equal :results, criteria.type
      assert_equal 'HbA1C', criteria.title
      assert_equal 1, criteria.subset_operators.length
      assert_equal 'RECENT', criteria.subset_operators[0].type
      assert_equal '2.16.840.1.113883.3.464.1.72', criteria.code_list_id
      assert_equal 'completed', criteria.status
      assert_equal nil, criteria.effective_time
      assert_equal HQMF::Range, criteria.value.class
      assert_equal nil, criteria.value.high
      assert criteria.value.low
      assert_equal '9', criteria.value.low.value
      assert_equal '%', criteria.value.low.unit

      criteria = @model.data_criteria('DiabetesMedAdministered')
      assert_equal :medications, criteria.type
      assert_equal 'DiabetesMedAdministered', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.94', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.high
      assert criteria.effective_time.low
      assert_equal true, criteria.effective_time.low.derived?
      assert_equal 'StartDate.add(new PQ(-2,"a"))', criteria.effective_time.low.expression

      criteria = @model.data_criteria('DiabetesMedSupplied')
      assert_equal :medication_supply, criteria.type
      assert_equal 'DiabetesMedSupplied', criteria.title
      assert_equal '2.16.840.1.113883.3.464.1.94', criteria.code_list_id
      assert criteria.effective_time
      assert_equal nil, criteria.effective_time.low
      assert criteria.effective_time.high
      assert_equal true, criteria.effective_time.high.derived?
      assert_equal 'EndDate.add(new PQ(-2,"a"))', criteria.effective_time.high.expression
      
      criteria = @model.data_criteria('anyDiabetes')
      assert_equal :derived, criteria.type
      assert_equal HQMF::DataCriteria::UNION, criteria.derivation_operator
      assert_equal 0, criteria.subset_operators.size
      assert_equal 2, criteria.children_criteria.length
      assert criteria.children_criteria.include? 'HasDiabetes'
      assert criteria.children_criteria.include? 'HasGestationalDiabetes'

      assert_nil @model.data_criteria('foo')
    end
    
    def test_to_json
      json = @model.to_json
      
      json[:title].must_equal "Sample Quality Measure Document"
      json[:description].must_equal "This is the measure description."
      
      logic = json[:population_criteria]
      
      population_criteria = logic[:IPP]
      
      ipp = {conjunction?:true, :preconditions=>[{:reference=>"ageBetween17and64",:conjunction_code=>"observationReference"}]}
      diff = ipp.diff_hash(population_criteria)
      assert diff.empty?, "differences: #{diff.to_json}"
      
      population_criteria = logic[:DENOM]
      denom =
      {conjunction?:true, :preconditions=>
          [{:preconditions=>[{:preconditions=>
            [
              { :reference=>"HasDiabetes",
                :conjunction_code=>"observationReference"},
                {:preconditions=>
                   [
                    {:reference=>"EDorInpatientEncounter",:conjunction_code=>"encounterReference"},
                    {:reference=>"AmbulatoryEncounter",:conjunction_code=>"encounterReference"}
                   ],
                 :conjunction_code=>"atLeastOneTrue"
                }
            ],
            :conjunction_code=>"allTrue"
           },
           {:reference=>"DiabetesMedAdministered",:conjunction_code=>"substanceAdministrationReference"},
           {:reference=>"DiabetesMedIntended",:conjunction_code=>"substanceAdministrationReference"},
           {:reference=>"DiabetesMedSupplied",:conjunction_code=>"supplyReference"},
           {:reference=>"DiabetesMedOrdered",:conjunction_code=>"supplyReference"}],
           :conjunction_code=>"atLeastOneTrue"
          }]
      }

      diff = denom.diff_hash(population_criteria)
      assert diff.empty?, "differences: #{diff.to_json}"
      
      population_criteria = logic[:NUMER]
      numer={conjunction?:true,:preconditions=>[{:reference=>"HbA1C", :conjunction_code=>"observationReference"}]}
      diff = numer.diff_hash(population_criteria)
      assert diff.empty?, "differences: #{diff.to_json}"
      
      
      population_criteria = logic[:DENEXCEP]
      denomexc = {conjunction?:true,
         :preconditions=>
          [{:preconditions=>
             [{:reference=>"HasPolycysticOvaries",:conjunction_code=>"observationReference"},
              {:reference=>"HasDiabetes",:conjunction_code=>"observationReference"}],
            :conjunction_code=>"allTrue"},
           {:reference=>"HasSteroidInducedDiabetes",:conjunction_code=>"observationReference"},
           {:reference=>"HasGestationalDiabetes",:conjunction_code=>"observationReference"}]}
           
      diff = denomexc.diff_hash(population_criteria)
      assert diff.empty?, "differences: #{diff.to_json}"
           
    end
  
  end
