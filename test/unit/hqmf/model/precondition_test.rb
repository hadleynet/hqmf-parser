require_relative '../../../test_helper'
module HQMFModel

  class PreconditionTest  < Test::Unit::TestCase
    def setup
    end
  
    def test_is_conjunction
      
      base_precondition = HQMF::Precondition.new(nil,nil,nil,nil,nil)
      
      precondition1 = HQMF::Precondition.new(nil,[],nil,nil,nil)
      
      assert !precondition1.conjunction?

      precondition2 = HQMF::Precondition.new(nil,nil,nil,nil,nil)
      
      assert !precondition1.conjunction?
      
      precondition3 = HQMF::Precondition.new(nil,[base_precondition.clone, base_precondition.clone],nil,nil,nil)

      assert precondition3.conjunction?
      
    end
  end
end
