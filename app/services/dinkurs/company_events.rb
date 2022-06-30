# frozen_string_literal: true

module Dinkurs
  include Dinkurs::Errors

  INVALID_KEY_MSG = 'Non existent company key'

  # Get Dinkurs events for a company, starting with a given date
  # and create an Event for each Dinkurs event fetched
  #
  # Business rules for fetching Dinkurs events:
  # 1. Reject events that started earlier than "events_start_date"
  # 2. Reject events that do not have a location specified
  #
  class CompanyEvents
    def self.create_from_dinkurs(company, events_start_date = 1.day.ago.to_date)
      return unless (events_hashes = dinkurs_events_hashes(company))

      now_or_future_events = events_hashes.reject { |event_hash| event_hash[:location].blank? || event_hash[:start_date] < events_start_date }
      now_or_future_events.each { |event_hash| Event.create(event_hash) }
    end

    # Turn each event from the Dinkurs REST request into a Hash of attributes for an Event
    # so we can easily create a new Event with the Hash.
    #
    # @return [Hash]
    private_class_method def self.dinkurs_events_hashes(company)
      co_details = "company.id: #{company.id} dinkurs_company_id: #{company.dinkurs_company_id}"
      events_data = dinkurs_events(company.dinkurs_company_id)

      raise Dinkurs::Errors::InvalidKey, co_details if events_data['company'] == INVALID_KEY_MSG

      events_data = events_data.dig('events', 'event')
      events_data = [events_data] if events_data.is_a? Hash
      # ^^ Parser expects an array of events.  HTTParty only returns an
      #    an array if there are multiple events, otherwise a Hash
      Dinkurs::EventsParser.parse(events_data, company.id)

    rescue Dinkurs::Errors::InvalidKey, Dinkurs::Errors::InvalidFormat => dinkurs_err
      raise dinkurs_err, "#{co_details} #{dinkurs_err.message}"
    rescue
      raise Dinkurs::Errors::InvalidFormat, "#{co_details}  Could not get event info from: #{events_data.inspect}"
    end

    private_class_method def self.dinkurs_events(dinkurs_company_id)
      Dinkurs::RestRequest.company_events_hash(dinkurs_company_id)
    end
  end
end
