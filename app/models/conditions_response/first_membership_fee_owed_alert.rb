#--------------------------
#
# @class  FirstMembershipFeeOwedAlert
#
# @desc Responsibility: Emails a user or member _after_ their membership fee is due
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund ashley.engelund@gmail.com (weedySeaDragon @ github)
# @date 2019-11-26
# @file first_membership_fee_owed_alert.rb
#
#--------------------------
class FirstMembershipFeeOwedAlert < UserEmailAlert

  def send_alert_this_day?(timing, config, user)

    if RequirementsForFirstMembershipFeeOwed.requirements_met?({ user: user})

      day_to_check = self.class.days_today_is_away_from( user.shf_application.when_approved , timing)
      send_on_day_number?(day_to_check, config)

    else
        false
    end
  end


  def mailer_method
    :first_membership_fee_owed
  end

end
