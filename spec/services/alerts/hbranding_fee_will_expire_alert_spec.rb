require 'rails_helper'

module Alerts
  RSpec.describe HBrandingFeeWillExpireAlert do

    subject { described_class.instance } # for readability

    let(:mock_log) { instance_double("ActivityLogger") }
    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)
    end

    describe 'Unit tests' do

      describe '.send_alert_this_day?(config, user)' do

        let(:config) { { days: [1, 7, 15, 30] } }
        let(:timing) { described_class.timing_before }

        let(:co_license_current) { instance_double("Company") }
        let(:co_license_expired) { instance_double("Company") }

        let(:most_recent_member_payment_start) { DateTime.new(2001, 6, 6) }
        let(:expired_license_date) { DateTime.new(2001, 12, 31) }

        describe 'uses Reqs::RequirementsForHBrandingFeeWillExpire to see if any license fee will be due' do

          it 'license fee will be due' do
            allow(subject).to receive(:send_on_day_number?).and_return(true)
            allow(co_license_current).to receive(:branding_expire_date).and_return(expired_license_date)
            allow(co_license_current).to receive(:earliest_current_member_fee_paid_time).and_return(most_recent_member_payment_start)
            allow(described_class).to receive(:days_today_is_away_from).and_return(1)

            expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?).with(entity: co_license_current).and_return(true)
            expect(subject.send_alert_this_day?(timing, config, co_license_current)).to be_truthy
          end

          it 'no license fee will be due' do
            expect(subject).not_to receive(:send_on_day_number?)
            expect(co_license_current).not_to receive(:branding_expire_date)
            expect(co_license_current).not_to receive(:earliest_current_member_fee_paid_time)
            expect(described_class).not_to receive(:days_today_is_away_from)

            expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?).with(entity: co_license_current).and_return(false)
            expect(subject.send_alert_this_day?(timing, config, co_license_current)).to be_falsey
          end

        end

        describe 'uses the company license payment as the basis for calculating the days from today' do

          it 'company license payment term has expired is the only situation that the requirements allows' do

            allow(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?).and_return(true)
            allow(subject).to receive(:send_on_day_number?).and_return(true)

            allow(co_license_expired).to receive(:branding_expire_date).and_return(expired_license_date)

            expect(described_class).to receive(:days_today_is_away_from).with(expired_license_date, anything).and_return(1)

            expect(subject.send_alert_this_day?(timing, config, co_license_expired)).to be_truthy
          end
        end
      end

      it '.mailer_method' do
        expect(subject.mailer_method).to eq :h_branding_fee_will_expire
      end

      it 'mailer_args' do
        mock_co = instance_double("Company", current_members: ['one', 2])
        expect(subject.mailer_args(mock_co)).to match_array([mock_co, ['one', 2]])
      end

    end

    describe 'Integration tests' do

      describe 'delivers emails to all current company members' do

        let(:testing_today) { DateTime.new(2020, 12, 20) }

        context 'timing is before (before the fee is due) ' do
          let(:timing_before) { described_class.timing_before }

          context 'config days: [10, 2]' do
            let(:config_10_2) { { days: [10, 2] } }
            let(:condition) { build(:condition, :before, config: config_10_2) }

            context 'today is 2 days before the company licensing fee is due' do

              it 'sends email to members in all companies that will be due in 2 days' do
                license_fee_expire_date = testing_today + 2 # '+ 2' will match the '2' in the configuration

                mock_member1 = instance_double("User", member: true)
                mock_member2 = instance_double("User", member: true)

                mock_co1 = instance_double("Company")
                allow(mock_co1).to receive(:current_members).and_return([mock_member1,
                                                                         mock_member2])
                allow(mock_co1).to receive(:branding_expire_date)
                                     .and_return(license_fee_expire_date)
                allow(mock_co1).to receive(:branding_license?).and_return(true)

                mock_co2 = instance_double("Company")
                allow(mock_co2).to receive(:current_members).and_return([mock_member2])
                allow(mock_co2).to receive(:branding_expire_date).and_return(nil)
                                                                 .and_return(license_fee_expire_date)
                allow(mock_co2).to receive(:branding_license?).and_return(true)

                allow(subject).to receive(:entities_to_check).and_return([mock_co1,
                                                                          mock_co2])

                expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?)
                                                                         .with(entity: mock_co1)
                                                                         .and_return(true)
                expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?)
                                                                         .with(entity: mock_co2)
                                                                         .and_return(true)

                expect(subject).to receive(:send_email)
                                     .with(mock_co1, mock_member1, anything)
                expect(subject).to receive(:send_email)
                                     .with(mock_co1, mock_member2, anything)

                expect(subject).to receive(:send_email)
                                     .with(mock_co2, mock_member2, anything)

                travel_to testing_today do
                  subject.condition_response(condition, mock_log)
                end
              end
            end

            context 'today is 3 before after the company licensing fee is due' do

              it 'no email is sent' do
                license_fee_expire_date = testing_today + 3 # '+ 3' will not match any of the configuration[:days]

                mock_member1 = instance_double("User", member: true)
                mock_member2 = instance_double("User", member: true)

                mock_co1 = instance_double("Company")
                allow(mock_co1).to receive(:current_members).and_return([mock_member1,
                                                                         mock_member2])
                allow(mock_co1).to receive(:branding_expire_date)
                                     .and_return(license_fee_expire_date)
                allow(mock_co1).to receive(:branding_license?).and_return(true)

                mock_co2 = instance_double("Company")
                allow(mock_co2).to receive(:current_members).and_return([mock_member2])
                allow(mock_co2).to receive(:branding_expire_date).and_return(nil)
                                                                 .and_return(license_fee_expire_date)
                allow(mock_co2).to receive(:branding_license?).and_return(true)

                allow(subject).to receive(:entities_to_check).and_return([mock_co1,
                                                                          mock_co2])

                expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?)
                                                                         .with(entity: mock_co1)
                                                                         .and_return(true)
                expect(Reqs::RequirementsForHBrandingFeeWillExpire).to receive(:requirements_met?)
                                                                         .with(entity: mock_co2)
                                                                         .and_return(true)

                expect(subject).not_to receive(:send_email)

                travel_to testing_today do
                  subject.condition_response(condition, mock_log)
                end
              end
            end
          end
        end
      end
    end
  end
end
