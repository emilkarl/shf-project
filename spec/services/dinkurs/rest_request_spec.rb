# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::RestRequest, vcr: { cassette_name: 'dinkurs/company_events' } do

  let(:dinkurs_company_test_id) { ENV['DINKURS_COMPANY_TEST_ID'] }
  let(:mock_response) { double(HTTParty::Response, parsed_response: {}) }

  it 'sends an HTTP get request to the Dinkurs URL with the company key set to the given dinkurs company id' do
    expect(HTTParty).to receive(:get)
                          .with("#{ENV['SHF_DINKURS_XML_URL']}?company_key=#{dinkurs_company_test_id}")
                          .and_return(mock_response)
    described_class.company_events_hash(dinkurs_company_test_id)
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
