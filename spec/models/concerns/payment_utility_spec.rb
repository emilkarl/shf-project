require 'rails_helper'
require 'shared_context/users'

# We use the User class to test the instance methods since it includes the PaymentUtility class

RSpec.describe User, type: :model do

  let(:membership_fee) { Payment::PAYMENT_TYPE_MEMBER }
  let(:branding_license_fee) { Payment::PAYMENT_TYPE_BRANDING }

  include_context 'create users'


  # ==================================
  #  Today = DECEMBER 1 for EVERY EXAMPLE
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '#most_recent_payment' do

    it 'if no payments, returns nil' do
      expect(user_no_payments.most_recent_payment(membership_fee)).to be_nil
      expect(user_no_payments.most_recent_payment(branding_license_fee)).to be_nil
    end

    it 'most recent is based on created_date' do
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(membership_fee)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(branding_license_fee)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
    end

  end


  describe '#payment_start_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_start_date(membership_fee)).to be_nil
      expect(user_no_payments.payment_start_date(branding_license_fee)).to be_nil
    end

    it 'is the start_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(membership_fee)
      expect(most_recent_membership_payment).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(branding_license_fee)
      expect(most_recent_membership_payment).to eq(nov_30)
    end
  end


  describe '#payment_expire_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_expire_date(membership_fee)).to be_nil
      expect(user_no_payments.payment_expire_date(branding_license_fee)).to be_nil
    end

    it 'is the expire_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(membership_fee)
      expect(most_recent_membership_payment).to eq(nov_29_next_year)
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(branding_license_fee)
      expect(most_recent_membership_payment).to eq(nov_29_next_year)
    end
  end


  describe '#payment_notes' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_notes(membership_fee)).to be_nil
      expect(user_no_payments.payment_notes(branding_license_fee)).to be_nil
    end

    it 'is the notes of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(membership_fee)
      expect(most_recent_membership_payment).to eq('nov_30 membership')
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(branding_license_fee)
      expect(most_recent_membership_payment).to eq('nov_30 branding')
    end
  end


  describe '#term_expired?' do

    it 'true if no payments have been made' do
      expect(user_no_payments.term_expired?(membership_fee)).to be_truthy
      expect(user_no_payments.term_expired?).to be_truthy
      expect(user_no_payments.term_expired?(branding_license_fee)).to be_truthy
    end

    it 'true if today is after the latest expire time (expire time < today)' do
      expect(user_paid_lastyear_nov_29.term_expired?(membership_fee)).to be_truthy
      expect(user_paid_lastyear_nov_29.term_expired?).to be_truthy
      u_co = user_paid_lastyear_nov_29.companies.first
      expect(u_co.term_expired?(branding_license_fee)).to be_truthy
      expect(u_co.term_expired?).to be_truthy
    end

    it 'true if today = latest expire time' do
      expect(user_paid_only_lastyear_dec_2.term_expired?(membership_fee)).to be_truthy
      expect(user_paid_only_lastyear_dec_2.term_expired?).to be_truthy
      u_co = user_paid_only_lastyear_dec_2.companies.first
      expect(u_co.term_expired?(branding_license_fee)).to be_truthy
      expect(u_co.term_expired?).to be_truthy
    end

    it 'false if today is before (<) latest expire time' do
      expect(user_membership_expires_EOD_feb2.term_expired?(membership_fee)).to be_falsey
      expect(user_membership_expires_EOD_feb2.term_expired?).to be_falsey
      u_co = user_membership_expires_EOD_feb2.companies.first
      expect(u_co.term_expired?(branding_license_fee)).to be_falsey
      expect(u_co.term_expired?).to be_falsey
    end
  end


  describe '#should_pay_now?' do

    it 'true if no payments have been made' do
      expect(user_no_payments.should_pay_now?).to be_truthy
      expect(build(:company).should_pay_now?).to be_truthy
    end

    it 'true if the expiration date < (today + cutoff duration)' do
      expect(user_membership_expires_EOD_feb2.should_pay_now?).to be_falsey
      u_co = user_membership_expires_EOD_feb2.companies.first
      expect(u_co.should_pay_now?).to be_falsey
    end

    it 'false if expiration date >= (today + cutoff duration)' do
      expect(user_membership_expires_EOD_feb3.should_pay_now?).to be_falsey
      u_co = user_membership_expires_EOD_feb3.companies.first
      expect(u_co.should_pay_now?).to be_falsey
    end

    it 'can give a cutoff duration to add to Today' do
      expect(user_membership_expires_EOD_dec8.should_pay_now?(1.week)).to be_truthy
      u_co = user_membership_expires_EOD_dec8.companies.first
      expect(u_co.should_pay_now?(1.week)).to be_truthy

      expect(user_membership_expires_EOD_dec9.should_pay_now?(1.week)).to be_falsey
      u_co = user_membership_expires_EOD_dec9.companies.first
      expect(u_co.should_pay_now?(1.week)).to be_falsey
    end
  end


  describe '#too_early_to_pay?' do

    it 'true if no payments have been made' do
      expect(user_no_payments.too_early_to_pay?).to be_falsey
      expect(build(:company).too_early_to_pay?).to be_falsey
    end

    it 'true if the expiration date < (today + cutoff duration)' do
      expect(user_membership_expires_EOD_feb2.too_early_to_pay?).to be_truthy
      u_co = user_membership_expires_EOD_feb2.companies.first
      expect(u_co.too_early_to_pay?).to be_truthy
    end

    it 'false if expiration date >= (today + cutoff duration)' do
      expect(user_membership_expires_EOD_feb3.too_early_to_pay?).to be_truthy
      u_co = user_membership_expires_EOD_feb3.companies.first
      expect(u_co.too_early_to_pay?).to be_truthy
    end

    it 'can give a cutoff duration to add to Today' do
      expect(user_membership_expires_EOD_dec8.too_early_to_pay?(1.week)).to be_falsey
      u_co = user_membership_expires_EOD_dec8.companies.first
      expect(u_co.too_early_to_pay?(1.week)).to be_falsey

      expect(user_membership_expires_EOD_dec9.too_early_to_pay?(1.week)).to be_truthy
      u_co = user_membership_expires_EOD_dec9.companies.first
      expect(u_co.too_early_to_pay?(1.week)).to be_truthy
    end
  end


  describe '.next_payment_dates returns an Array of [start_date, expire_date] for the next payment for the given entity id' do

    context 'entity not found raises ActiveRecord::RecordNotFound because it signals a problem in the program logic' do
      it 'User (membership fee and branding fee)' do
        expect { described_class.next_payment_dates(100, membership_fee) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { described_class.next_payment_dates(100, branding_license_fee) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it 'Company (branding fee)' do
        expect { described_class.next_payment_dates(100, branding_license_fee) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end


    context 'entity found' do

      context 'no payments' do

        describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)' do

          context 'User (membership fee and branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(User.next_payment_dates(user_no_payments.id, membership_fee)).to eq [dec_1, nov_30_next_year]
              expect(User.next_payment_dates(user_no_payments.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
            end
          end

          context 'Company (branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(Company.next_payment_dates(company_no_payments.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
            end
          end

        end # describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)'
      end # context 'no payments'


      context 'has payments' do

        context 'User (membership fee and branding fee)' do

          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, membership_fee)).to eq [dec_1, nov_30_next_year]
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, membership_fee)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
            expect(User.next_payment_dates(user_pays_every_nov30.id, branding_license_fee)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
          end
        end

        context 'Company (branding fee)' do
          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, branding_license_fee)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
          end
        end


        describe 'only uses the successful payments' do

          it 'User membership fee and branding fee' do
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, membership_fee)).to eq [dec_1, nov_30_next_year]
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
          end

          it 'Company branding fee' do
            expect(Company.next_payment_dates(company__unsuccessful_this_year.id, branding_license_fee)).to eq [dec_1, nov_30_next_year]
          end

        end

        describe 'what if you pass PAYMENT_TYPE_MEMBER for a Company?' do
          pending
        end

      end
    end
  end


  describe '.expire_date_for_start_date' do

    it 'is 1 calendar year minus 1 day' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR, 1, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR, 12, 31)
    end

    it 'leap year' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR + 2, 2, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR + 3, 1, 31)
    end

  end


  describe 'start_date_for_expire_date' do

    it 'is expire date minus 1 year + 1 day' do

    end


    it 'handles leap year' do

    end
  end


  describe 'other_date_for_given_date' do

    let(:start_2018_1_1) { Date.new(2018, 1, 1) }
    let(:expire_2018_12_31) { Date.new(2018, 12, 31) }

    it 'is_start_date is true by default' do
      expect(described_class.other_date_for_given_date( start_2018_1_1) ).to eq described_class.other_date_for_given_date( start_2018_1_1, is_start_date: true)
    end

    it 'given a start date, calc the expiration' do
      expect(described_class.other_date_for_given_date( start_2018_1_1) ).to eq expire_2018_12_31
    end

    it 'given an expiration date, calc the start date' do
      expect(described_class.other_date_for_given_date( expire_2018_12_31, is_start_date: false) ).to eq start_2018_1_1
    end

    describe 'handles leap years' do

      let(:start_2020_11_1) { Date.new(2020, 11, 1) }
      let(:expire_2021_10_31) { Date.new(2021, 10, 31) }

      it 'given a start date, calc the expiration' do
        expect(described_class.other_date_for_given_date( start_2020_11_1) ).to eq expire_2021_10_31
      end

      it 'given an expiration date, calc the start date' do
        expect(described_class.other_date_for_given_date( expire_2021_10_31, is_start_date: false) ).to eq start_2020_11_1
      end
    end

  end
end
