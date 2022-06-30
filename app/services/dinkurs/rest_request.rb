# frozen_string_literal: true

module Dinkurs
  # return a HTTParty parse response for a REST request to Dinkurs for a given Dinkurs company ID
  class RestRequest

    HTTPARTY_OPTS = { read_timeout: ENV['SHF_DINKURS_READ_TIMEOUT_SECS'].to_i,
                      max_retries: ENV['SHF_DINKURS_NUM_RETRIES'].to_i}

    def self.company_events_hash(dinkurs_company_id, options = HTTPARTY_OPTS)
      opts = HTTPARTY_OPTS.merge(options)
      HTTParty.get("#{ENV['SHF_DINKURS_XML_URL']}?company_key=#{dinkurs_company_id}", opts).parsed_response
    end
  end
end
