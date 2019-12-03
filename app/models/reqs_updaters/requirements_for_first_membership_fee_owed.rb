#--------------------------
#
# @class  RequirementsForFirstMembershipFeeOwed
#
# @desc Responsibility: Knows if a User owes their firstmembership fee. No
#   membership fee payments have been made since their application was approved.
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund ashley.engelund@gmail.com (weedySeaDragon @ github)
# @date 2019-11-26
# @file requirements_forrequirements_for_membership_fee_past_due_alert.rb
#
#--------------------------
class RequirementsForFirstMembershipFeeOwed < AbstractRequirements

  def self.has_expected_arguments?(args)
    args_have_keys?(args, [:user])
  end


  # Membership fee is due if application is approved AND there have been
  # no membership fee payments made since the application was approved.
  # This allows for the situation where someone might have applied and
  # been a member in the past. ()Although we currently do not support more than
  # one SHF Application for a user, we will in the future. [2019-11-26])
  #
  # TODO if PR 723 is merged, use user.has_successful_payments?( <membership fee payment> ) instead of most_recent_membership_payment.blank?
  #
  def self.requirements_met?(args)
    user = args[:user]
    user.has_approved_shf_application? &&
        (user.most_recent_membership_payment.blank? ||
            membership_expired_before_latest_app_approved?(user))
  end


  private

  def self.membership_expired_before_latest_app_approved?(user)
    # ensure the user has an approved application so we don't have problems with when_approved being nil
    user.has_approved_shf_application? &&
        (user.most_recent_membership_payment.expire_date < user.shf_application.when_approved)
  end
end
