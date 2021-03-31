require 'rails_helper'

RSpec.describe AdminOnly::Reports::PaymentsCoveringYearCsvReport, type: :model do

  let(:report_year) { 2021 }
  let(:subject) { described_class.new(report_year) }
  let(:prev_dec_31) { Time.parse("#{report_year - 1}-12-31") }
  let(:this_dec_31) { Time.parse("#{report_year}-12-31") }
  let(:next_jan_1) { Time.parse("#{report_year + 1}-01-01") }

  let(:header_line) { "this, is, the,csv,header,line\n" }

  it '.csv_adapter is Adapters::PaymentCoveringYearToCsvAdapter' do
    expect(described_class.csv_adapter).to eq Adapters::PaymentCoveringYearToCsvAdapter
  end

  it 'csv_header_args is the year' do
    expect(subject.csv_header_args).to eq [report_year]
  end

  it 'filename_start is framgangsrika-betalningar-<the given year>' do
    expect(subject.filename_start).to eq "framgangsrika-betalningar-#{report_year}"
  end


  describe 'initialize' do

    it 'sets the year to the given year' do
      report_for_2099 = described_class.new(2099)
      expect(report_for_2099.year).to eq 2099
    end
  end


  describe 'report_items' do

    it 'gets all completed payments that cover any part of the given year' do
      successful_prev_dec31 = create(:payment, :successful, start_date: prev_dec_31)
      successful_this_dec31 = create(:payment, :successful, start_date: this_dec_31)
      create(:payment, :successful, start_date: next_jan_1)

      create(:payment, :expired, start_date: prev_dec_31)
      create(:payment, :pending, start_date: this_dec_31)

      report_2021 = described_class.new(report_year)
      expect(report_2021.payments).to match_array([successful_prev_dec31, successful_this_dec31])
    end

    it 'report_items are the payments converted to PaymentCoveringYears' do
      successful_prev_dec31 = create(:payment, :successful, start_date: prev_dec_31)

      report_2021 = described_class.new(report_year)
      report_items = report_2021.report_items
      expect(report_items.size).to eq 1
      expect(report_items.first).to be_a PaymentCoveringYear
      expect(report_items.first.year).to eq report_year
      expect(report_items.first.payment).to eq successful_prev_dec31
    end
  end
end
