# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::RestRequest, vcr: { cassette_name: 'dinkurs/company_events' } do

  let(:dinkurs_company_test_id) { ENV['SHF_DINKURS_COMPANY_TEST_ID'] }
  let(:mock_response) { double(HTTParty::Response, parsed_response: {}) }
  let(:env_read_timeout) { ENV['SHF_DINKURS_READ_TIMEOUT_SECS'].to_i }
  let(:env_max_retries) { ENV['SHF_DINKURS_NUM_RETRIES'].to_i }


  it 'sends an HTTP get request to the Dinkurs URL with the company key set to the given dinkurs company id and options' do
    expect(HTTParty).to receive(:get)
                          .with("#{ENV['SHF_DINKURS_XML_URL']}?company_key=#{dinkurs_company_test_id}",
                                described_class::HTTPARTY_OPTS)
                          .and_return(mock_response)
    described_class.company_events_hash(dinkurs_company_test_id)
  end

  describe 'default options' do
    it "read_timeout is ENV['SHF_DINKURS_READ_TIMEOUT_SECS'] converted to an integer" do
      expect(described_class::HTTPARTY_OPTS[:read_timeout]).to eq(env_read_timeout)
    end

    it "max_retries is ENV['SHF_DINKURS_NUM_RETRIES'] converted to an integer" do
      expect(described_class::HTTPARTY_OPTS[:max_retries]).to eq(env_max_retries)
    end
  end

  it 'any given options will be merged with the default options' do
    expect(HTTParty).to receive(:get).with(anything, {max_retries: 42, some_other_option: 'blorf', read_timeout: env_read_timeout })
                                     .and_return(mock_response)
    described_class.company_events_hash(dinkurs_company_test_id, some_other_option: 'blorf', max_retries: 42)
  end

  it 'returns the parsed response of the get request' do
    allow(HTTParty).to receive(:get).and_return(mock_response)
    expect(mock_response).to receive(:parsed_response)
    described_class.company_events_hash(dinkurs_company_test_id)
  end

  it 'company_events_hash returns hash' do
    expect(described_class.company_events_hash(dinkurs_company_test_id)).to be_a(Hash)
  end

  it 'returns proper number of events' do
    expect(described_class.company_events_hash(dinkurs_company_test_id)['events']['event'].count)
      .to eq(11)
  end
end
