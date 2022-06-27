require 'rails_helper'

module Alerts
  RSpec.describe CompanyInfoIncompleteAlert do

    subject { described_class.instance }

    # don't write anything to the log
    let(:mock_log) { instance_double("ActivityLogger") }
    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)
    end

    describe 'Unit tests' do

      describe '.send_alert_this_day?(config, user)' do

        let(:timing) { CompanyInfoIncompleteAlert::TIMING_AFTER }

        context 'company has at least one member' do

          it 'requirements are met' do
            incomplete_co = instance_double("Company")
            allow(incomplete_co).to receive(:current_members).and_return(['some member'])
            allow(Reqs::CoInfoNotCompleteReqs).to receive(:requirements_met?)
                                                               .with({ entity: incomplete_co })
                                                               .and_return(true)
            co_earliest_fee_paid = DateTime.new(2020, 12, 8)
            expect(incomplete_co).to receive(:earliest_current_member_fee_paid_time)
                                       .and_return(co_earliest_fee_paid)
            expect(described_class).to receive(:days_today_is_away_from)
                                         .with(co_earliest_fee_paid, timing)
            expect(subject).to receive(:send_on_day_number?).with(anything, config)
                                                            .and_return(true)

            travel_to DateTime.new(2020, 12, 1) do
              expect(subject.send_alert_this_day?(timing, config, incomplete_co)).to be_truthy
            end
          end

          it 'requirements are not met (returns false immediately)' do
            complete_co = instance_double("Company")
            allow(complete_co).to receive(:current_members).and_return(['some member'])
            allow(Reqs::CoInfoNotCompleteReqs).to receive(:requirements_met?)
                                                               .with({ entity: complete_co })
                                                               .and_return(false)

            expect(complete_co).not_to receive(:earliest_current_member_fee_paid_time)

            expect(described_class).not_to receive(:days_today_is_away_from)

            expect(subject).not_to receive(:send_on_day_number?).with(anything, config)

            travel_to DateTime.new(2020, 12, 1) do
              expect(subject.send_alert_this_day?(timing, config, complete_co)).to be_falsey
            end
          end
        end

        context 'company has no members' do

          it 'returns false immediately' do

            incomplete_co = instance_double("Company")
            allow(incomplete_co).to receive(:current_members).and_return([])
            allow(Reqs::CoInfoNotCompleteReqs).to receive(:requirements_met?)
                                                               .with({ entity: incomplete_co })
                                                               .and_return(true)
            co_earliest_fee_paid = DateTime.new(2020, 12, 8)
            expect(incomplete_co).not_to receive(:earliest_current_member_fee_paid_time)

            expect(described_class).not_to receive(:days_today_is_away_from)
                                             .with(co_earliest_fee_paid, timing)
            expect(subject).not_to receive(:send_on_day_number?).with(anything, config)

            travel_to DateTime.new(2020, 12, 1) do
              expect(subject.send_alert_this_day?(timing, config, incomplete_co)).to be_falsey
            end
          end
        end
      end

      it '.mailer_method' do
        expect(subject.mailer_method).to eq :company_info_incomplete
      end

      it 'mailer_args' do
        member1 = instance_double("User")
        member2 = instance_double("User")
        incomplete_co = instance_double("Company")
        allow(incomplete_co).to receive(:current_members)
                                  .and_return([member1, member2])
        expect(subject.mailer_args(incomplete_co)).to match_array([incomplete_co, [member1, member2]])
      end
    end

    describe 'Integration tests' do

      describe 'delivers emails to all current company members' do

        it 'alerts sent to all comany members' do
          member1 = instance_double("User")
          member2 = instance_double("User")
          incomplete_co = instance_double("Company")
          allow(incomplete_co).to receive(:current_members)
                                    .and_return([member1, member2])
          allow(incomplete_co).to receive(:earliest_current_member_fee_paid_time)
                                    .and_return(DateTime.new(2018, 12, 2))
          allow(subject).to receive(:entities_to_check).and_return([incomplete_co])
          allow(Reqs::CoInfoNotCompleteReqs).to receive(:requirements_met?)
                                                             .with({ entity: incomplete_co })
                                                             .and_return(true)

          expect(subject).to receive(:send_email)
                               .with(incomplete_co,
                                     member1,
                                     mock_log)
          expect(subject).to receive(:send_email)
                               .with(incomplete_co,
                                     member2,
                                     mock_log)

          condition = build(:condition, :before, config: { days: [10, 2] })
          travel_to(DateTime.new(2018, 11, 22)) do
            subject.condition_response(condition, mock_log)
          end
        end
      end

    end
  end
end
