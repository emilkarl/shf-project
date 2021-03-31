require 'rails_helper'

RSpec.describe AdminOnly::Reports::PaymentsCsvReport, type: :model do

  it '.csv_adapter is Adapters::PaymentToCsvAdapter' do
    expect(described_class.csv_adapter).to eq Adapters::PaymentToCsvAdapter
  end

  it 'filename_start is betalningar' do
    expect(subject.filename_start).to eq 'betalningar'
  end


  it 'report_items are all Payments' do
    payment1_member = create(:membership_fee_payment, :successful)
    payment2_member_pending = create(:membership_fee_payment, :pending)
    payment3_branding = create(:h_branding_fee_payment)
    payment4_expired_member = create(:expired_membership_fee_payment)

    expect(subject.report_items).to match_array([payment1_member, payment2_member_pending,
                                                 payment3_branding, payment4_expired_member])
  end
end
