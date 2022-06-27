# frozen_string_literal: true

module Alerts

  # This emails a (former) member _after_ their membership has lapsed to alert them.
  #
  class MembershipLapsedAlert < UserEmailAlert

    def send_alert_this_day?(timing, config, user)

      return false unless Reqs::RequirementsForMembershipLapsed.satisfied?(entity: user)

      day_to_check = self.class.days_today_is_away_from(user.membership_expire_date, timing)

      send_on_day_number?(day_to_check, config)
    end

    def mailer_method
      :membership_lapsed
    end

  end
end
