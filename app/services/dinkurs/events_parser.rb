# frozen_string_literal: true

module Dinkurs
  class EventsParser
    include Dinkurs::Errors

    def self.parse(dinkurs_events, company_id)
      # @dinkurs_events = dinkurs_events
      # @company_id = company_id

      return nil unless dinkurs_events

      dinkurs_events.map do |event|
        make_event_hash(event, company_id)
      end
    end

    private_class_method def self.make_event_hash(event, company_id)
      { dinkurs_id: event['event_id'].first,
        name: event.dig('event_name', '__content__'),
        location: event.dig('event_place', '__content__'),
        fee: event.dig('event_fee', '__content__').to_f,
        start_date: event.dig('event_start', '__content__').to_date,
        description: event.dig('event_infotext', '__content__'),
        sign_up_url: event.dig('event_url_key', '__content__'),
        company_id: company_id }

    rescue
      raise Dinkurs::Errors::InvalidFormat, "Could not get event info from: #{event.inspect}"
    end
  end
end
