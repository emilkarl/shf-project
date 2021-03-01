#--------------------------
#
# @class RequirementsForRenewal
#
# @desc Responsibility: Knows what the requirements are for a Member to renew membership.
#       - Given a member, it can respond true or false if the membership renewal requirements are met.
#   Note that it is _not_ the responsibility of this class to know if the given member has been
#   unpaid so long that they cannot simply 'renew' but must re-apply.
#
#       This is a very simple class because the requirements are currently very simple.
#       The importance is that
#       IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/08/20
#
#--------------------------

class RequirementsForRenewal < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end

  def self.requirements_met?(args)
    requirements_excluding_payments_met?(args[:user]) &&
      payment_requirements_met?(args[:user])
  end

  def self.requirements_excluding_payments_met?(user)
    user.can_renew_today? &&
      user.has_approved_shf_application? &&
      membership_guidelines_checklist_done?(user) # &&
      #doc_uploaded_during_this_membership_term?(user)
  end

  # @return [Boolean] - if a user must have a completed Membership Guidelines checklist,
  #   return true if has been completed  (false if not completed)
  # else if the user does not have to have a completed Membership Guidelines checklist,
  #   return true (we assume it's fine)
  def self.membership_guidelines_checklist_done?(user)
    UserChecklistManager.completed_membership_guidelines_checklist?(user)
  end

  # @return [Boolean] - Has the user uploaded at least 1 document since the start of this membership term?
  # FIXME - in the last year of the membership term or during the payment term?
  #   - what if the member paid for 2 terms in advance?
  def self.doc_uploaded_during_this_membership_term?(user)
    user.file_uploaded_during_this_membership_term?
  end

  def self.max_days_can_still_renew
    AdminOnly::AppConfiguration.config_to_use.membership_expired_grace_period
  end

  def self.payment_requirements_met?(user)
    user.payments_current?
  end
end
