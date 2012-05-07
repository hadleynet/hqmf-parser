module HQMF
  
  # preconditions can be in several places.
  #
  # precondition -> preconditions
  # restriction -> preconditions
  #
  # also, restrictions can be on the following, which can then have preconditions
  #   restrictions
  #   comparisons
  #   preconditions
  #
  class PreconditionExtractor
   
   
    # TODO: This should probably NOT be done.  We are pulling restriction preconditions directly into the tree
    # instead, we should push these down to the data criteria under temporal restrictions, or however else they are handled
    def self.extract_preconditions_from_restrictions(restrictions,data_criteria_by_id)
      return [] unless restrictions
      preconditions = []
      restrictions.each do |restriction|
        preconditions.concat(extract_preconditions_from_restriction(restriction,data_criteria_by_id))
      end
      preconditions      
    end
    
    # get all the preconditions for a restriction (this should eventually get pushed down to data criteria)
    # we need to iterate down 
    #   restriction.preconditions
    #   restriction.comparison
    #   restriction.restriction
    def self.extract_preconditions_from_restriction(restriction,data_criteria_by_id)
      preconditions = []
      if (!restriction[:from_parent])
        # get the precondtions off of the restriction
        preconditions.concat(HQMF::PreconditionConverter.parse_and_merge_preconditions(restriction[:preconditions],data_criteria_by_id)) if restriction[:preconditions]
        # check comparison and convert it to a precondition
        preconditions << convert_comparison_to_precondition(restriction[:comparison], data_criteria_by_id) if restriction[:comparison]
        # check restrictions
        preconditions.concat(extract_preconditions_from_restrictions(restriction[:restrictions], data_criteria_by_id)) if restriction[:restrictions]
      end
      preconditions
    end


    # we want the comparisons to be converted to the leaf preconditions
    def self.convert_comparison_to_precondition(comparison, data_criteria_by_id)

      data_criteria = data_criteria_by_id[comparison[:data_criteria_id]]

      reference = HQMF::Reference.new(data_criteria.id)
      conjunction_code = "#{data_criteria.type}Reference"

      preconditions = []
      if comparison[:restrictions]
        # check for preconditions on restrictions
        Kernel.warn('restrictions on comparsions should be pushed down as part of the restriction conversion')
        preconditions = extract_preconditions_from_restrictions(comparison[:restrictions], data_criteria_by_id) 

        # push the restrictions down to the data criteria
        Kernel.warn('restrictions not pushed down to comparisons are not picked up')
        HQMF::RestrictionConverter.applyRestrictionsToDataCriteria(data_criteria, comparison[:restrictions],data_criteria_by_id)
      end

      HQMF::Precondition.new(preconditions,reference,conjunction_code, false)
    end
    
  end  
end
