# frozen_string_literal: true

module Dinkurs
  # return a HTTParty parse response for a REST request to Dinkurs for a given Dinkurs company ID
  class RestRequest

    def self.company_events_hash(dinkurs_company_id)
      HTTParty.get("#{ENV['SHF_DINKURS_XML_URL']}?company_key=#{dinkurs_company_id}").parsed_response
    end
  end
end
