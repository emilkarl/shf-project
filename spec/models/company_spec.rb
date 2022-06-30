require 'rails_helper'

require 'shared_context/companies'

require_relative File.join('..', '..', 'app', 'services', 'address_exporter')


RSpec.describe Company, type: :model do

  include_context 'create companies'

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    DatabaseCleaner.clean_with(:truncation)  # FIXME: why is this needed? should be set in rails_helper

    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)

    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    simple_guideline = build(:user_checklist, :completed, master_checklist: build(:membership_guidelines_master_checklist))
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(simple_guideline)
  end


  let(:user) { create(:user) }

  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }
  let(:payment_date_2020) { Time.zone.local(2020, 3, 15) }
  let(:jan1_2010) { Date.new(2010, 1, 1) }
  let(:dec_12_2018) { Date.new(2018, 12, 1) }
  let(:jan1_2019) { Date.new(2019, 1, 1) }

  let(:cat1) { build(:business_category, name: 'cat1') }
  let(:cat2) { build(:business_category, name: 'cat2') }
  let(:cat3) { build(:business_category, name: 'cat3') }
  let(:cat4) { build(:business_category, name: 'cat4') }
  let(:cat5) { build(:business_category, name: 'cat5') }
  let(:cat6) { build(:business_category, name: 'cat6') }
  let(:cat7) { build(:business_category, name: 'cat7') }
  let(:cat8) { build(:business_category, name: 'cat8') }

  let(:current_member_1) { create(:member, membership_status: :current_member) }
  let(:company_1_org_nr) { current_member_1.companies.first.company_number }
  let(:current_member_2) { create(:member, company_number: company_1_org_nr, membership_status: :current_member) }
  let(:current_member_3) { create(:member, company_number: company_1_org_nr, membership_status: :current_member) }

  let(:company_1) do
    co = current_member_1.companies.first
    allow(co).to receive(:current_members).and_return([current_member_1, current_member_2, current_member_3])
    co
  end


  let(:applicant_new) { create(:user_with_membership_app, company_number: company_1.company_number) }
  let(:applicant_under_review) { create(:user_with_membership_app, application_status: :under_review, company_number: company_1.company_number) }
  let(:applicant_rejected) { create(:user_with_membership_app, application_status: :rejected, company_number: company_1.company_number) }

  let(:in_grace_pd) { create(:member, company_number: company_1.company_number, membership_status: :in_grace_period) }
  let(:former_member_1) { create(:member, company_number: company_1.company_number, membership_status: :former_member) }

  let(:employee1) { create(:user, member: true) }
  let(:employee2) { create(:user, member: true) }
  let(:employee3) { create(:user, member: true) }


  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:company)).to be_valid
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

    it { is_expected.to allow_value('abcdef').for(:dinkurs_company_id) }
    it { is_expected.not_to allow_value('åäöÅÄÖ').for(:dinkurs_company_id) }

    describe 'uniqueness of company_number' do
      let(:msg) { I18n.t('activerecord.errors.models.company.attributes.company_number.taken') }
      subject { FactoryBot.build(:company) }

      it 'uniqueness of company_number' do
        expect(subject).to validate_uniqueness_of(:company_number)
                               .with_message(msg).case_insensitive
      end
    end

    describe 'swedish org number' do
      it { is_expected.to allow_values('5560360793', '2120000142')
                              .for(:company_number) }
      it { is_expected.not_to allow_values('0123456789', '212000')
                                  .for(:company_number) }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:business_categories).through(:shf_applications) }
    it { is_expected.to have_many(:company_applications) }
    it { is_expected.to have_many(:shf_applications).through(:company_applications) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true) }
    it do
      is_expected.to have_many(:pictures).dependent(:destroy)
                         .class_name(Ckeditor::Picture)
    end
    it { is_expected.to have_many(:users).through(:shf_applications) }
    it { is_expected.to have_many(:payments) }
    it { is_expected.to accept_nested_attributes_for(:payments).allow_destroy(false) }
    it { is_expected.to have_many(:events).dependent(:destroy) }
  end


  describe 'Scopes' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    let(:app_co1_user1) do
      app           = create(:shf_application, user: user1)
      app.companies = [complete_co1]
      app
    end
    let(:app_co1_user2) do
      app           = create(:shf_application, user: user2)
      app.companies = [complete_co1]
      app
    end

    let!(:no_name_1_address) { create(:company, name: '') }
    let!(:nil_name_1_address) { create(:company, name: nil) }

    let!(:co_with_1_address) { create(:company, name: 'Has 1 Address', num_addresses: 1) }
    let!(:co_with_2_addresses)  { create(:company, name: 'Has 2 Addresses', num_addresses: 2) }
    let!(:co_no_address) { create(:company, name: 'No Address', num_addresses: 0) }

    let!(:co_with_address_no_region) do
      co = create(:company, name: 'Has Address, nil region', num_addresses: 1)
      co.addresses.first.update(region: nil)
      co
    end

    let!(:co_with_2_addresses_1_no_region) do
      co = create(:company, name: 'Has 2 Addresses, 1 with nil region', num_addresses: 2)
      co.addresses.first.update(region: nil)
      co
    end

    let!(:co_with_2_addresses_all_no_region) do
      co = create(:company, name: 'Has 2 Addresses, all with nil region', num_addresses: 2)
      co.addresses.first.update(region: nil)
      co.addresses.last.update(region: nil)
      co
    end


    describe '.has_name' do
      it 'only companies with a name that is not an empty string' do
        expect(described_class.has_name).to match_array([co_with_1_address,
                                                              co_with_2_addresses,
                                                              co_no_address,
                                                              co_with_address_no_region,
                                                              co_with_2_addresses_1_no_region,
                                                              co_with_2_addresses_all_no_region])
      end
    end


    describe '.blank_name' do
      it 'companies with a name that is an empty string OR name is nil' do
        expect(described_class.blank_name).to match_array([no_name_1_address,
                                                                nil_name_1_address])
      end
    end


    describe '.has_address' do
      it 'only Companies that have at least 1 address' do
        expect(described_class.has_address).to match_array([no_name_1_address,
                                                                 nil_name_1_address,
                                                                 co_with_1_address,
                                                                 co_with_2_addresses,
                                                                 co_with_address_no_region,
                                                                 co_with_2_addresses_1_no_region,
                                                                 co_with_2_addresses_all_no_region
                                                                ])
      end
    end


    describe '.lacking_address' do
      it 'Companies with no addresses' do
        expect(described_class.lacking_address).to match_array([co_no_address])
      end
    end


    describe '.addresses_have_region' do
      it 'Companies with at least 1 address where the address region is not nil' do
        expect(described_class.addresses_have_region).to match_array([no_name_1_address,
                                       nil_name_1_address,
                                       co_with_1_address,
                                       co_with_2_addresses,
                                       co_with_2_addresses_1_no_region])
      end
    end


    describe '.no_address_or_lacks_region' do
      it 'Companies with no address OR all addresses are missing the region' do
        expect(described_class.no_address_or_lacks_region).to match_array([co_no_address,
                                                                                co_with_address_no_region,
                                                                                co_with_2_addresses_all_no_region])
      end
    end


    describe '.categories (all categories for current members)' do

      it 'returns 3 current members, 3 non-accepted applicants, each with 1 unique category' do
        current_member_1.shf_application.business_categories = [cat1]
        current_member_2.shf_application.business_categories = [cat2]
        current_member_3.shf_application.business_categories = [cat3]
        applicant_new.shf_application.business_categories = [cat4]
        applicant_under_review.shf_application.business_categories = [cat5]
        applicant_rejected.shf_application.business_categories = [cat6]
        in_grace_pd.shf_application.business_categories = [cat7]
        former_member_1.shf_application.business_categories = [cat8]

        expect(company_1.business_categories.count).to eq 3
        expect(company_1.business_categories.map(&:name))
          .to contain_exactly('cat1', 'cat2', 'cat3')
      end

      it 'returns distinct categories: 1 category if all current members have the same category' do
        current_member_1.shf_application.business_categories = [cat1]
        current_member_2.shf_application.business_categories = [cat1]
        current_member_3.shf_application.business_categories = [cat1]
        in_grace_pd.shf_application.business_categories = [cat7]
        former_member_1.shf_application.business_categories = [cat8]

        expect(company_1.business_categories.count).to eq 1
        expect(company_1.business_categories.distinct.map(&:name))
          .to contain_exactly('cat1')
      end
    end


    describe '.information_complete' do

      it 'calls .has_name' do
        expect(described_class).to receive(:has_name).and_call_original
        described_class.information_complete
      end

      it 'calls .addresses_have_region' do
        expect(described_class).to receive(:addresses_have_region)
        described_class.information_complete
      end

      it 'is all Companies .has_name AND all Companies .addresses_have_region' do
        expect(described_class.information_complete).to match_array(Company.has_name & Company.addresses_have_region)
      end
    end


    describe '.not_complete' do

      it 'calls .blank_name' do
        expect(described_class).to receive(:blank_name).and_call_original
        described_class.not_complete
      end

      it 'calls .no_address_or_lacks_region' do
        expect(described_class).to receive(:no_address_or_lacks_region).and_call_original
        described_class.not_complete
      end

      it 'is all Companies .blank_name OR all Companies .no_address_or_lacks_region' do
        expect(described_class.not_complete).to match_array(Company.blank_name.to_a +
                                                            Company.no_address_or_lacks_region.to_a)
      end
    end


    describe '.address_visible' do

      it 'only returns companies that have one or more visible addresses' do
        co_no_viz_addresses
        expect(Company.address_visible).
          to match_array([no_name_1_address,
                              nil_name_1_address,
                              co_with_1_address,
                              co_with_2_addresses,
                              co_with_address_no_region,
                              co_with_2_addresses_1_no_region,
                              co_with_2_addresses_all_no_region])
      end
    end

    describe '.with_members' do

      it 'calls User.current_member to get all current members' do
        expect(User).to receive(:current_member).and_return([])
        described_class.with_members
      end

      it 'returns no companies if no members' do
        FactoryBot.create(:user_with_membership_app)
        FactoryBot.create(:user_with_membership_app)

        allow(User).to receive(:current_member).and_return([])
        expect(Company.with_members).to be_empty
      end

      context 'has members in good standing (current)' do

        it 'returns all companies that have members that are in good standing (current)' do
          member1 = FactoryBot.create(:user_with_membership_app)
          co1 = member1.shf_application.companies.first

          member2 = FactoryBot.create(:user_with_membership_app)
          co2 = member2.shf_application.companies.first

          expect(User).to receive(:current_member).and_return([member1, member2])

          expect(Company.with_members).to match_array([co1, co2])
        end

        it 'returns a company only once even if multiple current members' do
          member1 = FactoryBot.create(:user_with_membership_app)
          co1 = member1.shf_application.companies.first
          member2 = FactoryBot.create(:user_with_membership_app,
                                      company_number: co1.company_number)
          allow(User).to receive(:current_member).and_return([member1, member2])

          expect(Company.with_members).to contain_exactly(co1)
        end
      end
    end


    describe '.branding_licensed' do

      it 'returns all currently-licensed companies' do
        payment1_co1.update(expire_date: Time.zone.today - 1.day)
        payment2.update(expire_date: Time.zone.today - 1.day)
        expect(Company.branding_licensed).to be_empty

        payment1_co1.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co1)

        payment2.update(expire_date: Time.zone.today)
        expect(Company.branding_licensed).to contain_exactly(complete_co1)
      end
    end


    describe '.searchable' do

      it 'calls .information_complete' do
        expect(described_class).to receive(:information_complete).and_call_original
        described_class.searchable
      end

      it 'calls .with_members' do
        allow(described_class).to receive(:information_complete).and_call_original
        expect(described_class).to receive(:with_members).and_call_original
        described_class.searchable
      end

      it 'calls .branding_licensed' do
        allow(described_class).to receive(:information_complete).and_call_original
        allow(described_class).to receive(:with_members).and_call_original
        expect(described_class).to receive(:branding_licensed).and_call_original
        described_class.searchable
      end

      it 'returns no companies if no companies exist' do
        expect(Company.searchable).to be_empty
      end

      context 'company information is complete' do

        context 'branding license payment is current (is paid up)' do

          let(:co1_current) do
            create(:h_branding_fee_payment, company: complete_co1)
            complete_co1
          end

          it 'has members in good standing (current members)'do
            co1_user = co1_current.shf_applications.first.user
            allow(User).to receive(:current_member).and_return([co1_user])

            expect(described_class.searchable).to contain_exactly(co1_current)
          end

          it 'has no members in good standing (no current members)' do
            complete_and_paid_co_user = co1_current.shf_applications.first.user
            allow(complete_and_paid_co_user).to receive(:payments_current?).and_return(false)

            expect(described_class.searchable).to be_empty
          end
        end

      end
    end


    describe '.at_addresses(addresses)' do

      let(:kista_co) do
        create(:company,
               name:           'Stockholm Co',
               street_address: 'Rehnsgatan 15',
               post_code:      '113 57',
               city:           'Stockholm')
      end

      let(:stockholm_co) do
        create(:company,
               name:           'Kista Co',
               street_address: 'AKALLALÄNKEN 10',
               post_code:      '164 74',
               city:           'Kista')
      end



      it 'returns all companies at these addresses' do
        kista_co
        stockholm_co

        kista_address = Address.find_by_city('Kista')
        expect(Company.at_addresses([kista_address]).map(&:name)).to match_array(['Kista Co'])
      end

      it 'no companies if addresses is empty' do
        kista_co
        stockholm_co

        expect(Company.at_addresses([]).size).to eq 0
      end

    end # end context '.at_addresses(addresses)' do


    describe '.with_dinkurs_id' do

      it 'returns nil if no companies with non-empty dinkurs_company_id' do
        company_3_addrs
        expect(Company.with_dinkurs_id).to be_empty
      end

      it 'returns companies with dinkurs_company_id' do
        complete_co1
        complete_co2
        co_no_viz_addresses
        company_3_addrs.update_attribute(:dinkurs_company_id, ENV['SHF_DINKURS_COMPANY_TEST_ID'])
        expect(Company.with_dinkurs_id).not_to be_empty
        expect(Company.with_dinkurs_id).to contain_exactly(company_3_addrs)
      end

    end

  end


  describe 'h-brand JPG cache management' do
    let(:company) { create(:company) }
    let(:company2) { create(:company) }

    before(:each) { Rails.cache.clear(company.cache_key('h_brand')) }

    it { expect(company.cache_key('h_brand')).to eq "company_#{company.id}_cache_h_brand" }

    describe 'h_brand_jpg' do
      it 'returns nil if no cached image' do
        expect(company.h_brand_jpg).to be_nil
      end

      it 'returns cached image if present' do
        Rails.cache.write(company.cache_key('h_brand'), file_fixture('image.png'))
        expect(company.h_brand_jpg).to_not be_nil
        expect(company.h_brand_jpg).to eq file_fixture('image.png')
      end
    end

    describe 'h_brand_jpg=' do
      it 'caches image' do
        expect(company.h_brand_jpg).to be_nil
        company.h_brand_jpg = file_fixture('image.png')
        expect(company.h_brand_jpg).to_not be_nil
        expect(company.h_brand_jpg).to eq file_fixture('image.png')
      end
    end

    describe 'clear_h_brand_jpg_cache' do
      it 'clears cache' do
        company.h_brand_jpg = file_fixture('image.png')
        expect(company.h_brand_jpg).to_not be_nil
        company.clear_h_brand_jpg_cache
        expect(company.h_brand_jpg).to be_nil
      end
    end

    describe '.clear_all_h_brand_jpg_caches' do
      it 'clears image cache for all companies' do
        company.h_brand_jpg = file_fixture('image.png')
        company2.h_brand_jpg = file_fixture('image.png')
        expect(company.h_brand_jpg).to_not be_nil
        expect(company2.h_brand_jpg).to_not be_nil
        Company.clear_all_h_brand_jpg_caches
        expect(company.h_brand_jpg).to be_nil
        expect(company2.h_brand_jpg).to be_nil
      end
    end

    describe 'after_update :clear_h_brand_jpg_cache' do

      it 'is called if name changes' do
        expect(company).to receive(:clear_h_brand_jpg_cache).once
        company.update_attributes(name: 'new_company_name')
      end

      it 'is not called if other attribute changes' do
        expect(company).not_to receive(:clear_h_brand_jpg_cache)
        company.update_attributes(phone_number: '1234',
                                  email: 'this_company@mail.com',
                                  website: 'nonesuch')
      end
    end
  end



  describe 'destroy or nullify associated records when a Company is destroyed' do

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:application1) do
      create(:shf_application, company: company_3_addrs,
             company_number:            company_3_addrs.company_number, user: user1)
    end
    let(:application2) do
      create(:shf_application, company: company_3_addrs,
             company_number:            company_3_addrs.company_number, user: user2)
    end

    let(:payment_type) { Payment::PAYMENT_TYPE_BRANDING }
    let(:brand_pymt1) do
      create(:payment, company: company_3_addrs, payment_type: payment_type)
    end
    let(:brand_pymt2) do
      create(:payment, company: company_3_addrs, payment_type: payment_type)
    end

    let(:picture1) do
      pic                = Ckeditor::Picture.new
      pic.company_id     = company_3_addrs.id
      pic.data_file_name = 'test1'
      pic.save!(validate: false)
      pic
    end

    let(:picture2) do
      pic                = Ckeditor::Picture.new
      pic.company_id     = company_3_addrs.id
      pic.data_file_name = 'test2'
      pic.save!(validate: false)
      pic
    end


    it 'destroy_checks is called before destory' do
      co = create(:company)
      expect(co).to receive(:destroy_checks)
      co.destroy
    end


    it 'addresses' do
      expect { company_3_addrs }.to change(Address, :count).by(3)
      expect { company_3_addrs.destroy }.to change(Address, :count).by(-3)
    end

    it 'events' do
      event1
      event2
      expect { company_3_addrs.destroy }.to change(Event, :count).by(-2)
    end

    it 'pictures' do
      Ckeditor::Picture.for_company_id = company_3_addrs.id
      Ckeditor::Picture.images_category = nil

      picture1
      picture2

      expect(company_3_addrs.pictures.count).to eq 2
      expect { company_3_addrs.destroy }.to change(Ckeditor::Picture, :count).by(-2)
    end

    it 'payments are NOT deleted if a company is deleted; company_id is set to nil' do
      # create the payments
      brand_pymt1
      brand_pymt2
      expect(company_3_addrs.payments.count).to eq 2
      expect(Payment.where(company_id: nil).count).to eq 0

      expect { company_3_addrs.destroy }.not_to change(Payment, :count)
      expect(Payment.where(company_id: nil).count).to eq 2
    end

  end


  describe 'destroy_checks' do

    it 'calls record_deleted_payorinfo_in_payment_notes' do
      co = create(:company)
      expect(co).to receive(:record_deleted_payorinfo_in_payment_notes)
      co.destroy
    end
  end


  describe 'Dinkurs events update management' do

    around(:each) do |example|
      travel_to(Time.zone.local(2018, 6, 1)) do
        example.run
      end
    end

    it '#events_start_date returns starting date for stored events' do
      expect(company_3_addrs.events_start_date).to eq 1.day.ago.to_date
    end

    context '#fetch_dinkurs_events', :vcr do
      it 'returns nil if no dinkurs_company_id' do
        expect(build(:company).fetch_dinkurs_events).to be_nil
      end

      it 'deletes previous events and returns nil if no dinkurs_company_id' do
        event1
        event2
        expect(company_3_addrs.events.count).to eq 2
        expect(company_3_addrs.fetch_dinkurs_events).to be_nil
        expect(company_3_addrs.events.count).to eq 0
      end

      it 'deletes previous events and returns nil if invalid dinkurs_company_id' do
        company_3_addrs.dinkurs_company_id = 'nonesuch'
        event1
        event2
        expect(company_3_addrs.events.count).to eq 2
        expect(company_3_addrs.fetch_dinkurs_events).to be_nil
        expect(company_3_addrs.events.count).to eq 0
      end

      it 'returns events for valid dinkurs_company_id' do
        company_3_addrs.dinkurs_company_id = ENV['SHF_DINKURS_COMPANY_TEST_ID']
        expect(company_3_addrs.events.count).to eq 0
        expect(company_3_addrs.fetch_dinkurs_events).to_not be_nil
        expect(company_3_addrs.events.count).to_not eq 0
      end
    end

    context '#valid_key_and_fetch_dinkurs_events?', :vcr do
      it 'returns true if dinkurs key is unchanged and never fetches events' do
        expect(Dinkurs::CompanyEvents).not_to receive(:create_from_dinkurs)
        expect(company_3_addrs.valid_key_and_fetch_dinkurs_events?).to eq true
      end

      it 'returns true if events are fetched' do
        company_3_addrs.dinkurs_company_id = ENV['SHF_DINKURS_COMPANY_TEST_ID']
        co = build(:company)
        allow(co).to receive(:fetch_dinkurs_events).and_return({})
        expect(co.valid_key_and_fetch_dinkurs_events?).to eq true
      end

      it 'adds model error and returns false if invalid dinkurs key' do
        company_3_addrs.dinkurs_company_id = 'xyz'
        err = I18n.t('activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_key')

        allow(Dinkurs::CompanyEvents).to receive(:create_from_dinkurs).and_raise(Dinkurs::Errors::InvalidCompanyKey)
        result = company_3_addrs.valid_key_and_fetch_dinkurs_events?

        expect(result).to eq false
        expect(company_3_addrs.errors.full_messages.first).to match(/#{err}/)
      end

      it 'adds model error and returns false if invalid dinkurs format' do
        company_3_addrs.dinkurs_company_id = 'xyz'
        err = I18n.t('activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_format')

        allow(Dinkurs::CompanyEvents).to receive(:create_from_dinkurs).and_raise(Dinkurs::Errors::CannotConvertToHash)
        result = company_3_addrs.valid_key_and_fetch_dinkurs_events?

        expect(result).to eq false
        expect(company_3_addrs.errors.full_messages.first).to include(err)
      end
    end
  end


  describe 'current_members' do

    it '(env== test) current members are users that are current members' do
      current_member = create(:member, membership_status: :current_member)
      co = current_member.companies.first
      create(:member, company_number: co.company_number, membership_status: :in_grace_period)
      another_current_member = create(:member, company_number: co.company_number, membership_status: :current_member)

      expect(co.current_members).to match_array([current_member, another_current_member])
    end

    it 'is empty if no members' do
      expect(build(:company).current_members).to be_empty
    end

    it 'is empty if all members expiration date has past' do
      no_current_members_co = create(:company)
      create(:member, company_number: no_current_members_co.company_number, membership_status: :in_grace_period)
      create(:member, company_number: no_current_members_co.company_number, membership_status: :former_member)

      expect(no_current_members_co.current_members).to be_empty
    end

    it 'only returns members with current membership' do
      co_mixed_membership = create(:company)
      current_member = create(:member, company_number: co_mixed_membership.company_number, membership_status: :current_member)
      create(:member, company_number: co_mixed_membership.company_number, membership_status: :in_grace_period)
      create(:member, company_number: co_mixed_membership.company_number, membership_status: :former_member)
      # refresh all materialized views because that's where the list of current members comes from
      DbViews::MemberAndCategory.refresh
      DbViews::CompanyAndMember.refresh
      expect(co_mixed_membership.current_members).to match_array([current_member])
    end

  end


  describe 'accepted_applicants' do

    it 'empty if no applications' do
      # This shouldn't really happen.
      expect(build(:company).accepted_applicants).to be_empty
    end

    context 'there are applications' do

      it 'empty if none are accepted' do
        all_states_except_accepted = ShfApplication.all_states - [:accepted]
        new_app1 = build(:shf_application, state: :new)
        co = new_app1.companies.first

        (all_states_except_accepted - [:new]).each do | state |
          build(:shf_application, state: state, company_number: co.company_number)
        end

        expect(co.accepted_applicants).to be_empty
      end


      it 'all users from all accepted applications' do
        app1 = create(:shf_application, :accepted)
        co = app1.companies.first
        user1 = app1.user
        app2 = create(:shf_application, :accepted, company_number: co.company_number)
        user2 = app2.user
        create(:shf_application, :rejected, company_number: co.company_number)

        expect(co.accepted_applicants).to match_array([user1, user2])
      end
    end
  end


  describe 'error_if_has_applications?' do
    it 'false if there are no applications in any state other than being destroyed' do
      skip
    end

    context 'there are applications in a state other than being destroyed' do
      it 'throws an abort error with the error message' do
        skip
      end
    end
  end


  describe 'main_address' do

    it 'creates a blank address if none exists' do
      company = create(:company, num_addresses: 0)

      expect(company.addresses.count).to eq 0

      # calling .main_address should instantiate an Address
      expect(company.main_address).to be_an_instance_of Address
      expect(company.addresses.to_ary.count).to eq 1

    end

    it 'returns mail address for company' do
      company = create(:company, num_addresses: 3)
      company.addresses[1].update(mail: true)
      expect(company.main_address).to eq(company.addresses.second)
    end

    it 'returns the first address for the company if no mail address' do
      company = create(:company, num_addresses: 3)
      expect(company.addresses.count).to eq 3
      expect(company.main_address).to eq(company.addresses.first)
    end

  end


  describe 'se_mailing_csv_str (export CSV string for postal address)' do

    it 'just commas (no data between them) if there is no address' do
      company = build(:company)

      company.addresses.delete_all

      expected_str = AddressExporter.se_mailing_csv_str(Address.new)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

    it 'uses the main address (1 address)' do

      company = create(:company)

      expected_str = AddressExporter.se_mailing_csv_str(company.main_address)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

    it 'uses the main address when it has multiple addresses' do

      company = create(:company, num_addresses: 3)

      expected_str = AddressExporter.se_mailing_csv_str(company.main_address)

      expect(company.se_mailing_csv_str).to eq expected_str

    end

  end


  describe 'sanitize_website' do

    let(:company_sani_site) { create(:company) }

    it 'website = "javascript://alert(alert-text)"' do
      company_sani_site.website = "javascript://alert('alert-text')"
      company_sani_site.save
      expect(company_sani_site.website).to eq("://alert('alert-text')")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company_sani_site.website = "<script>alert('scriptalert(Boo!)')</script>"
      company_sani_site.save
      expect(company_sani_site.website).to eq ''
    end

  end

  describe 'sanitize_description' do

    let(:company_sani_desc) { create(:company) }

    it 'removes unwanted/malicious text' do
      company_sani_desc.description = "<img src=javascript:alert('Hello')>"
      company_sani_desc.save
      expect(company_sani_desc.description).to eq("<img>")
    end

    it 'website = "<script>alert("scriptalert("Boo!")")</script>"' do
      company_sani_desc.description = "<script>alert('scriptalert(Boo!)')</script>"
      company_sani_desc.save
      expect(company_sani_desc.description).to eq ''
    end
  end


  context 'payment and branding license period' do

    describe 'branding_expire_date' do
      it 'returns date for latest completed payment' do
        payment1_co1
        expect(complete_co1.branding_expire_date).to eq payment1_co1.expire_date
        payment2
        expect(complete_co1.branding_expire_date).to eq payment2.expire_date
      end
    end

    describe 'branding_payment_notes' do
      it 'returns notes for latest completed payment' do
        payment1_co1
        expect(complete_co1.branding_payment_notes).to eq payment1_co1.notes
        payment2
        expect(complete_co1.branding_payment_notes).to eq payment2.notes
      end
    end

    describe 'most_recent_branding_payment' do
      it 'returns latest completed payment' do
        payment1_co1
        expect(complete_co1.most_recent_branding_payment).to eq payment1_co1
        payment2
        expect(complete_co1.most_recent_branding_payment).to eq payment2
      end
    end


    describe '.self.next_membership_payment_dates' do

      around(:each) do |example|
        travel_to(payment_date_2018) do
          example.run
        end
      end

      it "returns today's date for first payment start date" do
        expect(Company.next_membership_payment_dates(complete_co1.id)[0]).to eq Time.zone.today
      end

      it 'returns one year later for first payment expire date' do
        expect(Company.next_membership_payment_dates(complete_co1.id)[1])
            .to eq Time.zone.today + 1.year - 1.day
      end

      it 'returns date-after-expiration for second payment start date' do
        payment1_co1
        expect(Company.next_membership_payment_dates(complete_co1.id)[0])
            .to eq Time.zone.today + 1.year
      end

      it 'returns one year later for second payment expire date' do
        payment1_co1
        expect(Company.next_membership_payment_dates(complete_co1.id)[1])
            .to eq Time.zone.today + 1.year + 1.year - 1.day
      end

      context 'if next payment occurs after prior payment expire date' do

        it 'returns actual payment date for start date' do
          payment1_co1
          travel_back # travel back from the travel_to around each example
          travel_to(payment_date_2020) do
            expect(Company.next_membership_payment_dates(complete_co1.id)[0])
              .to eq payment_date_2020
          end
        end

        it 'returns payment date + 1 year for expire date' do
          payment1_co1
          travel_back # travel back from the travel_to around each example
          travel_to(payment_date_2020) do
            expect(Company.next_membership_payment_dates(complete_co1.id)[1])
              .to eq payment_date_2020 + 1.year - 1.day
          end
        end
      end

    end
  end

  describe 'approved_applications_from_members' do
    let(:cmpy1) { create(:company, company_number: '5560360793') }
    let(:cmpy2) { create(:company, company_number: '5562252998') }

    let(:user1) { create(:user, member: true) }
    let(:user2) { create(:user, member: true) }
    let(:user3) { create(:user, member: true) }
    let(:user4) { create(:user) }
    let(:user5) { create(:user, member: true) }
    let(:user6) { create(:user, member: true) }

    let!(:cmpy1_app1) do
      m           = create(:shf_application, :accepted, user: user1)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app2) do
      m           = create(:shf_application, :accepted, user: user2)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy1_app3) do
      m           = create(:shf_application, :rejected, user: user3)
      m.companies = [cmpy1]
      m
    end

    let!(:cmpy2_app1) do
      m           = create(:shf_application, :accepted, user: user4)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app2) do
      m           = create(:shf_application, :accepted, user: user5)
      m.companies = [cmpy2]
      m
    end

    let!(:cmpy2_app3) do
      m           = create(:shf_application, :accepted, user: user6)
      m.companies = [cmpy2]
      m
    end

    it 'returns only apps that are 1) accepted and 2) from members' do
      expect(cmpy1.approved_applications_from_members)
          .to contain_exactly(cmpy1_app1, cmpy1_app2)

      expect(cmpy2.approved_applications_from_members)
          .to contain_exactly(cmpy2_app2, cmpy2_app3)
    end
  end


  describe 'any_visible_addresses?' do
    it 'true if there are any visible addresses' do
      skip
    end
  end


  describe 'addresses_region_names' do
    it 'get all region names used by addresses, with no duplicates' do
      skip
    end

    it 'do not include regions if their addresses are not visible at that level' do
      skip
    end
  end


  describe 'kommuns_names' do
    it 'get all kommun names used by addresses, with no duplicates' do
      skip
    end


    it 'do not include kommuns if their addresses are not visible at that level' do
      skip
    end
  end


  describe 'cities_names' do
    it 'get all city names used by addresses, with no duplicates' do
      skip
    end


    it 'do not include cities if their addresses are not visible at that level' do
      skip
    end
  end


  describe '.categories_names' do

    let(:cat1_subcat1) { cat1.children.create(name: 'cat1_subcat1') }
    let(:cat1_subcat2) { cat1.children.create(name: 'cat1_subcat2') }
    let(:cat1_subcat3) { cat1.children.create(name: 'cat1_subcat3') }

    before(:each) do
      current_member_1.shf_application.business_categories = [cat1]
      current_member_2.shf_application.business_categories = [cat2]
      current_member_3.shf_application.business_categories = [cat3]
      applicant_new.shf_application.business_categories = [cat4]
      applicant_under_review.shf_application.business_categories = [cat5]
      applicant_rejected.shf_application..business_categories = [cat6]
      cat1_subcat1
      cat1_subcat2
      cat1_subcat3
    end


    it 'returns all categories only for current members' do
      expect(company_1.categories_names(false).count).to eq 3
      expect(company_1.categories_names(false))
          .to contain_exactly('cat1', 'cat2', 'cat3')
    end

    it 'returns categories and subcategories only for current members' do
      expect(company_1.categories_names(true).count).to eq 6
      expect(company_1.categories_names(true))
          .to contain_exactly('cat1', 'cat1_subcat1', 'cat1_subcat2', 'cat1_subcat3', 'cat2', 'cat3')
    end

    it 'does not return categories for non-members' do
      current_member_1.update_attribute(:membership_status, :in_grace_period)
      expect(company_1.categories_names(false).count).to eq 2
      expect(company_1.categories_names(false))
          .to contain_exactly('cat2', 'cat3')
    end
  end

  describe 'get_short_h_brand_url' do
    context 'there is already a shortened url in the table' do
      it 'returns shortened url' do
        url = 'http://localhost:3000/anvandare/0/company_h_brand?company_id=1'
        expect(co_with_short_h_brand_url.get_short_h_brand_url(url)).to eq('http://www.tinyurl.com/hbrand')
      end
    end
    context 'there is no shortened url in the table and ShortenUrl.short is called' do
      it 'saves the result if the result is not nil and returns shortened url' do
        url = 'http://localhost:3000/anvandare/1/company_h_brand'
        allow(ShortenUrl).to receive(:short).with(url).and_return('http://tinyurl.com/short_url')
        expect(complete_co1.get_short_h_brand_url(url)).to eq(ShortenUrl.short(url))
        expect(complete_co1.short_h_brand_url).to eq(ShortenUrl.short(url))
      end
      it 'does not save anything if the result is nil and returns unshortened url' do
        url = 'http://localhost:3000/anvandare/1/company_h_brand'
        allow(ShortenUrl).to receive(:short).with(url).and_return(nil)
        expect(complete_co1.get_short_h_brand_url(url)).to eq(url)
        expect(complete_co1.short_h_brand_url).to eq(nil)
      end
    end
  end


  describe 'branding_license? always returns true || false, never nil' do

    context 'no payments' do

      it 'is false (never nil)' do
        expect(complete_co2.branding_license?).not_to be_nil
        expect(complete_co2.branding_license?).to be_falsey
      end

    end


    context 'payments expire before today - always false (never nil)' do

      let(:past_payments_co) { create(:company) }

      payment_statuses = Payment::ORDER_PAYMENT_STATUS.keys.reject(&:nil?)

      payment_statuses.each do | payment_status |

        context "#{payment_status} payments" do

          let(:payment_2017_10_1) do
            create(:payment, user: user, status: Payment::ORDER_PAYMENT_STATUS[payment_status],
                   company:        past_payments_co,
                   payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                   notes:          'these are notes for branding payment_2017_10_1, past_payments_co',
                   start_date:     payment_date_2017,
                   expire_date:    (payment_date_2017.advance(days: 364) ) )
          end

          it 'is false (never nil)' do
            travel_to(Date.new(2019, 1, 1)) do
              payment_2017_10_1
              expect(past_payments_co.payments.size).to eq 1
              expect(past_payments_co.branding_license?).not_to be_nil
              expect(past_payments_co.branding_license?).to be false
            end

          end
        end #  context 'successful payments'

      end
    end # context 'payments before today'


    context 'payments expire after today' do

      let(:payment_start)  { Time.zone.local(2018, 1, 3)   }
      let(:payment_expire) { Time.zone.local(2019, 1, 2)   }
      let(:pretend_today)  { Time.zone.local(2018, 10, 10) }

      context 'successful payments' do

        let(:successful_payments_co) { create(:company) }

        let(:payment_2018_1_3) do
          create(:payment, :successful, user: user,
                 company:        successful_payments_co,
                 payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                 notes:          'these are notes for branding payment_2018_1_3, successful_payments_co',
                 start_date:     payment_start,
                 expire_date:    Company.expire_date_for_start_date(payment_start) )
        end

        it 'is true' do
          travel_to( pretend_today ) do
            payment_2018_1_3
            expect(successful_payments_co.payments.size).to eq 1
            expect(successful_payments_co.branding_license?).to be_truthy
          end
        end
      end


      context 'not successful payments' do

        let(:not_successful_payments_co) { create(:company) }

        payment_statuses = Payment::ORDER_PAYMENT_STATUS.keys.reject(&:nil?).reject{|status| status == 'successful'}

        payment_statuses.each do | payment_status |

          let(:payment_2018_1_3) do
            create(:payment, user: user, status: Payment::ORDER_PAYMENT_STATUS[payment_status],
                   company:        not_successful_payments_co,
                   payment_type:   Payment::PAYMENT_TYPE_BRANDING,
                   notes:          'these are notes for branding payment_2018_1_3, not_successful_payments_co',
                   start_date:     payment_start,
                   expire_date:    Company.expire_date_for_start_date(payment_start) )
          end

          it "payment status #{payment_status}: is false (never nil)" do
            travel_to( pretend_today ) do
              payment_2018_1_3
              expect(not_successful_payments_co.payments.size).to eq 1
              expect(not_successful_payments_co.branding_license?).not_to be_nil
              expect(not_successful_payments_co.branding_license?).to be_falsey
            end
          end

        end

      end # context 'not successful payments'

    end # context 'payments after today'
  end # describe 'branding_license?'


  describe 'earliest_current_member_fee_paid_time' do

    before(:each) { allow(Membership).to receive(:term_length).and_return(1.year) }

    it 'is nil if there are no current members' do
      co = build(:company)
      allow(co).to receive(:current_members).and_return([])
      expect( co.earliest_current_member_fee_paid_time ).to be_nil
    end

    it 'is the earliest membership_fee paid date for all current members' do
      dec_3 = Time.new(2018, 12, 3)
      dec_5 = Time.new(2018, 12, 5)

      current_member_1.payments.each do |payment|
        payment.update_attribute(:created_at, dec_5)
      end
      current_member_2.payments.each do |payment|
        payment.update_attribute(:created_at, dec_3)
      end
      current_member_3.payments.each do |payment|
        payment.update_attribute(:created_at, dec_5)
      end

      expect(company_1.current_members.size).to eq 3
      expect( company_1.earliest_current_member_fee_paid_time ).to eq dec_3
    end
  end


  describe 'information_complete?' do
    it 'is the result of CoInfoCompleteReqs.requirements_met?' do
      co = build(:company)
      expect(Reqs::CoInfoCompleteReqs).to receive(:satisfied?).with(entity: co)
      co.information_complete?
    end
  end


  describe 'missing_information' do
    it 'gets the list of missing information text from CoInfoCompleteReqs.missing_errors' do
      co = build(:company)
      expect(Reqs::CoInfoCompleteReqs).to receive(:missing_info).with({entity: co})
      co.missing_information
    end
  end

  describe 'membership_changed' do

    it 'notifies observers with self' do
      given_co = build(:company)
      expect(given_co).to receive(:notify_observers).with(given_co, nil, nil)
      given_co.membership_changed
    end

    describe 'observers notified' do
      it 'materialized views that involve the company membership status are refreshed' do
        expect(DbViews::CurrentCompany).to receive(:company_status_changed)
        expect(DbViews::CompanyAndMember).to receive(:company_status_changed)

        DbViews::MemberAndCategory.refresh # must populate this because CompanyAndCategory depends on it
        expect(DbViews::CompanyAndCategory).to receive(:company_status_changed)
        build(:company).membership_changed
      end
    end
  end

  describe 'in_good_standing?' do
    let(:co) { build(:company) }

    context 'required information for a company is complete' do
      before(:each) { allow(co).to receive(:information_complete?).and_return(true) }

      it 'true if branding license payment is current' do
        allow(co).to receive(:branding_license_current?).and_return(true)
        expect(co.in_good_standing?).to be_truthy
      end

      it 'false if branding license payment is not current' do
        allow(co).to receive(:branding_license_current?).and_return(false)
        expect(co.in_good_standing?).to be_falsey
      end
    end

    it 'false if required information for a company is not complete' do
      allow(co).to receive(:information_complete?).and_return(false)
      expect(co.in_good_standing?).to be_falsey
    end
  end

  describe 'searchable?' do
    let(:co) { build(:company) }

    context 'has a current branding license' do
      before(:each) { allow(co).to receive(:branding_license_current?).and_return(true) }

      it 'true if there are any current members' do
        allow(co).to receive(:current_members).and_return([build(:user)])
        expect(co.searchable?).to be_truthy
      end

      it 'false if there are no current members' do
        allow(co).to receive(:current_members).and_return([])
        expect(co.searchable?).to be_falsey
      end
    end

    it 'false if there is no current branding license' do
      allow(co).to receive(:branding_license_current?).and_return(false)
      expect(co.searchable?).to be_falsey
    end
  end


  describe 'missing_region?' do

    describe 'false if all addresses have a region' do
      it 'only address has a region' do
        expect(complete_co1.missing_region?).to be_falsey
      end

      it 'all addresses have a region' do
        complete_co1.addresses << build(:company_address, addressable: complete_co1)
        complete_co1.addresses << build(:company_address, addressable: complete_co1)
        expect(complete_co1.missing_region?).to be_falsey
      end
    end

    describe 'true if 1 or more addresses have no region' do

      it 'only address does not have a region' do
        co_nil_region.addresses.first.region = nil  # just in case it's been changed by other tests
        expect(co_nil_region.missing_region?).to be_truthy
      end

      it 'one of many addresses does not have a region' do
        co_nil_region.addresses.first.region = nil  # just in case it's been changed by other tests

      # add some valid addresses (Region is not nil)
        co_nil_region.addresses << build(:company_address, addressable: co_nil_region)
        co_nil_region.addresses << build(:company_address, addressable: co_nil_region)

        expect(co_nil_region.missing_region?).to be_truthy
      end
    end
  end

end
