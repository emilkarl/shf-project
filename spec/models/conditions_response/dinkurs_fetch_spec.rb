require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_conditions'


RSpec.describe DinkursFetch, type: :model do

  let(:mock_log) { instance_double("ActivityLogger", {info: ''}) }

  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }

  let(:company_with_dinkurs_id) do
    co = build(:company, dinkurs_company_id: ENV['SHF_DINKURS_COMPANY_TEST_ID'])
    allow(co).to receive(:id).and_return(42)
    allow(co).to receive(:fetch_dinkurs_events)
    allow(co).to receive(:reload)
    co
  end

  let(:company_without_dinkurs_id) do
    co = build(:company)
    allow(co).to receive(:id).and_return(9)
    allow(co).to receive(:reload)
    co
  end

  describe '.condition_response' do

    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end

    it 'gets all Companies with dinkurs ids' do
      expect(Company).to receive(:with_dinkurs_id).and_return([])
      described_class.condition_response(condition, mock_log)
    end

    it 'has each company fetch their Dinkurs events' do
      allow(Company).to receive(:with_dinkurs_id).and_return([company_with_dinkurs_id, company_without_dinkurs_id])
      expect(company_with_dinkurs_id).to receive(:fetch_dinkurs_events)
      expect(company_without_dinkurs_id).to receive(:fetch_dinkurs_events)

      described_class.condition_response(condition, mock_log)
    end

    it 'writes the company events count to the log' do
      allow(Company).to receive(:with_dinkurs_id).and_return([company_with_dinkurs_id])

      expect(mock_log).to receive(:info).with('Fetching Dinkurs events for company id=42  SomeCompany')
      expect(mock_log).to receive(:info).with(/\s\sCompany 42: \d+ events\./)

      described_class.condition_response(condition, mock_log)
    end
  end
end
