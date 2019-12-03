
#--------------------------
#
# @class  RequirementsForFirstMembershipFeeOwedNot
#
# @desc Responsibility:  opposite of the RequirementsForFirstMembershipFeeOwed
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund ashley.engelund@gmail.com (weedySeaDragon @ github)
# @date 2019-11-26
# @file requirements_for_first_membership_fee_owed_not.rb
#
#--------------------------
class RequirementsForFirstMembershipFeeOwedNot < AbstractOppositeRequirements


  def self.opposite_class
    RequirementsForFirstMembershipFeeOwed
  end

end
