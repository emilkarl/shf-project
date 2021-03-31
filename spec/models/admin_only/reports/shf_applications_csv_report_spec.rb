require 'rails_helper'

RSpec.describe AdminOnly::Reports::ShfApplicationsCsvReport, type: :model do

  it '.csv_adapter is Adapters::ShfApplicationToCsvAdapter' do
    expect(described_class.csv_adapter).to eq Adapters::ShfApplicationToCsvAdapter
  end

  it 'filename_start is Ansokningar' do
    expect(subject.filename_start).to eq "Ansokningar"
  end


  it 'report_items are all ShfApplications' do
    app1 = create(:shf_application, contact_email: 'app1@example.com')
    app2 = create(:shf_application, contact_email: 'app2@example.com')

    expect(subject.report_items).to match_array([app1, app2])
  end
end
