# frozen_string_literal: true

module Dinkurs
  include Dinkurs::Errors

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

    rescue Dinkurs::Errors::InvalidCompanyKey, Dinkurs::Errors::CannotConvertToHash => dinkurs_error
      raise dinkurs_error
    rescue => error
      raise Dinkurs::Errors::UnknownError, "#{error.class} #{error} - #{co_event_details(company, events_hashes)}"
    end

    # Turn each event from the Dinkurs REST request into a Hash of attributes for an Event
    # so we can easily create a new Event with the Hash.
    #
    # @return [Hash, nil]
    def self.dinkurs_events_hashes(company)
      events_data = dinkurs_events(company.dinkurs_company_id)

      raise Dinkurs::Errors::InvalidCompanyKey, co_event_details(company, events_data) if events_data['company'] == Errors::INVALID_KEY_MSG

      events_data = events_data.dig('events', 'event')
      events_data = [events_data] if events_data.is_a? Hash
      # ^^ Parser expects an array of events.  HTTParty only returns an
      #    an array if there are multiple events, otherwise a Hash
      Dinkurs::EventsParser.parse(events_data, company.id)

    rescue Dinkurs::Errors::BadEventInfo, Dinkurs::Errors::InvalidCompanyKey => dinkurs_error
      raise dinkurs_error
    rescue => error
      raise Dinkurs::Errors::CannotConvertToHash, "#{error.class} #{error} - #{co_event_details(company, events_data)}"
    end

    def self.dinkurs_events(dinkurs_company_id)
      Dinkurs::RestRequest.company_events_hash(dinkurs_company_id)
    end

    # Standardize a string for showing helpful data in an error message
    # @return [String] - company id and dinkurs id and the events_data inspect string
    private_class_method def self.co_event_details(company, events_data = nil)
      co_details = "company.id: #{company.id} dinkurs_company_id: #{company.dinkurs_company_id}"
      "#{co_details} : events_data: #{events_data.inspect}"
    end

  end
end
