#--------------------------
#
# @class RequirementsForMembership
#
# @desc Responsibility: Knows what the membership requirements are for a User
#       - Given a user, it can respond true or false if membership requirements are met.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file requirements_for_membership.rb
#
#--------------------------


class RequirementsForMembership < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end


  def self.requirements_met?(args)
    user = args[:user]

    requirements_excluding_payments_met?(user) &&
      payment_requirements_met?(user)
  end

  # FIXME - be consistent everywhere about whether the requirements include payments or not
  def self.requirements_excluding_payments_met?(user)
    user.has_approved_shf_application? &&
      membership_guidelines_checklist_done?(user)
  end

  # @return [Boolean] - if a user must have a completed Membership Guidelines checklist,
  #   return true if has been completed  (false if not completed)
  # else if the user does not have to have a completed Membership Guidelines checklist,
  #   return true (we assume it's fine)
  def self.membership_guidelines_checklist_done?(user)
    UserChecklistManager.completed_membership_guidelines_checklist?(user)
  end

  def self.payment_requirements_met?(user)
    user.payments_current?
  end
end # RequirementsForMembership
