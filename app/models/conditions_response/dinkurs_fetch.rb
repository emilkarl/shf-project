# Fetch dinkurs events

class DinkursFetch < ConditionResponder

  def self.condition_response(condition, log, use_slack_notification: true)

    confirm_correct_timing(get_timing(condition), TIMING_EVERY_DAY, log)

    Company.with_dinkurs_id.each do |company|
      log.info("Fetching Dinkurs events for company id=#{company.id}  #{company.name}")
      company.fetch_dinkurs_events
      company.reload
      log.info("  Company #{company.id}: #{company.events.count} events.")
    end
  end
end
