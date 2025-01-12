require 'rails_helper'

module Reqs
  RSpec.describe RequirementsForHBrandingFeeWillExpire do
    let(:subject) { Reqs::RequirementsForHBrandingFeeWillExpire }


    describe '.requirements_met?' do

      let(:jan_1) { Date.new(2019, 1, 1) }
      let(:jan_2) { Date.new(2019, 1, 2) }
      let(:jan_2_500_days_ago) { jan_2 - 500.days }

      let(:june_19) { Date.new(2019, 6, 19) }

      let(:jan_5_2020) { Date.new(2020, 1, 5) }

      around(:each) do |example|
        travel_to(jan_2) do
          example.run
        end
      end

      context 'always false if company does not have current members' do

        it 'is false (no fee due)' do
          co = build(:company)
          allow(co).to receive(:current_members).and_return([])
          expect(subject.requirements_met?({ entity: co })).to be_falsey
        end
      end

      context 'company has current members' do
        let(:paid_membership_only) { create(:member, membership_status: :current_member, first_day: jan_1) }
        let(:paid_member_co) do
          co = paid_membership_only.companies.first
          allow(co).to receive(:current_members).and_return([paid_membership_only])
          co
        end

        context 'branding fee not paid' do
          it 'is false' do
            expect(subject.requirements_met?({ entity: paid_member_co })).to be_falsey
          end
        end

        context 'branding fee paid ' do
          context 'branding fee has not expired (is current)' do

            it 'is true (will be due)' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_1,
                     expire_date: Company.expire_date_for_start_date(jan_1))
              expect(subject.requirements_met?({ entity: paid_member_co })).to be_truthy
            end
          end

          context 'branding fee has expired' do

            it 'is false' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_2_500_days_ago,
                     expire_date: Company.expire_date_for_start_date(jan_2_500_days_ago))

              expect(subject.requirements_met?({ entity: paid_member_co })).to be_falsey
            end
          end
        end # 'branding fee paid'
      end #  context 'company has current members'
    end
  end
end
