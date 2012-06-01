require_relative '../../../test_helper'

class HQFGeneratorTest < Test::Unit::TestCase
  def setup
    # Parse the sample file and convert to the model
    hqmf_xml = File.open("test/fixtures/2.0/NQF59New.xml").read
    doc = HQMF2::Document.new(hqmf_xml)
    model = doc.to_model
    # serialize the model using the generator back to XML and then
    # reparse it
    @hqmf_xml = HQMF2::Generator::ModelProcessor.to_hqmf(model)
    doc = HQMF2::Document.new(hqmf_xml)
    @model = doc.to_model
  end

  def test_roundtrip
    assert_equal 'foo', @model.id
    assert_equal "Sample Quality Measure Document", @model.title
    assert_equal "This is the measure description.", @model.description
    data_criteria = @model.all_data_criteria
    assert_equal 30, data_criteria.length

    criteria = @model.data_criteria('DummyProcedureAfterHasDiabetes')
    assert_equal :procedures, criteria.type

    criteria = @model.data_criteria('EDorInpatientEncounter')
    assert_equal :encounters, criteria.type
  end
  
  def test_schema_valid
    doc = Nokogiri.XML(@hqmf_xml)
    xsd_file = File.open("test/fixtures/2.0/schema/EMeasureNew.xsd")
    xsd = Nokogiri::XML.Schema(xsd_file)
    error_count = 0
    xsd.validate(doc).each do |error|
      puts error.message
      error_count = error_count + 1
    end
    assert_equal 0, error_count
  end
end
