require 'rails_helper'


RSpec.describe Adapters::ShfApplicationToCsvAdapter do

  it 'creates a CsvRow from a ShfApplication' do

    shf_app = create(:shf_application)

    time_packet_sent = Time.zone.now
    shf_app.user.date_membership_packet_sent = time_packet_sent

    csv_row = described_class.new(shf_app).as_target

    user_path = "/anvandare/#{shf_app.user.id}"
    company_path = "/hundforetag/#{shf_app.companies.last.id}"

    expected_str = "#{shf_app.contact_email},#{shf_app.user.email},Firstname,Lastname,,#{time_packet_sent.to_date},Ny,#{Date.current},\"Business Category\",\"#{shf_app.companies.last.name}\",\"#{ I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: user_path) }\",\"Aldrig betald\",\"#{I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: company_path) }\",\"Aldrig betald\",\"Hundforetagarevägen 1\",'310 40,\"Harplinge\",Ale,MyString,Sverige"

    expect(csv_row.to_s).to eq expected_str
  end

end
