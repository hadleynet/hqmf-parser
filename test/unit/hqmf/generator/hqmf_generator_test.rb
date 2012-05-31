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
    assert_equal "Sample Quality Measure Document", @model.title
    assert_equal "This is the measure description.", @model.description
  end
  
  def test_schema_valid
    # TODO test generated XML is valid according to the HQMF V2 schema
  end
end
