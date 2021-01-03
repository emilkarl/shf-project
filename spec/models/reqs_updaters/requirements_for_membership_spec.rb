require 'rails_helper'

RSpec.describe RequirementsForMembership, type: :model do

  before(:each) do
    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end

  let(:subject) { RequirementsForMembership }
  let(:user) { build(:user) }

  describe '.has_expected_arguments?' do

    it 'args has expected :user key' do
      expect(subject.has_expected_arguments?({ user: 'some user' })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end

  describe '.membership_guidelines_checklist_done?' do
    it 'calls UserChecklistManager to see if the user has completed the Ethical guidelines checklist' do
      expect(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?)
                                        .with(user)
      subject.membership_guidelines_checklist_done?(user)
    end
  end

  describe '.requirements_excluding_payments_met?' do
    it 'all non-payment requirements  are && together' do
      expect(user).to receive(:has_approved_shf_application?)
                        .and_return(true)
      expect(subject).to receive(:membership_guidelines_checklist_done?)
                           .and_return(true)

      expect(subject.requirements_excluding_payments_met?(user)).to be_truthy
    end
  end

  describe '.requirements_met?' do

    it 'all non-payment requirements && all payment requirements' do
      expect(subject).to receive(:requirements_excluding_payments_met?).with(user)
                                                                       .and_return(true)
      expect(subject).to receive(:payment_requirements_met?).with(user)
                                                            .and_return(true)

      expect(subject.requirements_met?(user: user)).to be_truthy
    end
  end

  describe '.payment_requirements_met?' do

    it 'result = user.payments_current?' do
      u = build(:user)
      expect(u).to receive(:payments_current?).and_return(true)
      expect(subject.payment_requirements_met?(u)).to be_truthy

      expect(u).to receive(:payments_current?).and_return(false)
      expect(subject.payment_requirements_met?(u)).to be_falsey
    end
  end

  describe 'Integration tests' do
    let(:member) { create(:member_with_membership_app) }

    let(:member_expired_payment) do
      create(:membership_fee_payment,
             :successful,
             user: member,
             start_date: Time.zone.today - 1.year - 1.month,
             expire_date: Time.zone.today - 1.year)
    end

    let(:member_current_payment) do
      start_date, expire_date = User.next_membership_payment_dates(member.id)
      create(:membership_fee_payment,
             :successful,
             user: member,
             start_date: start_date,
             expire_date: expire_date)
    end

    describe '.requirements_met?' do

      context 'has approved application' do

        let(:approved_applicant) do
          approved_app = create(:shf_application, :accepted)
          approved_app.user
        end

        context 'membership guidelines ARE agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true) }

          it 'true if membership payment made (and it has not expired)' do
            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_truthy
          end

          it 'false if membership payment made and it HAS expired' do
            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            travel_to(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end

        context 'membership guidelines NOT agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false) }

          it 'false if membership payment made AND it does not expire until AFTER the start of the membership guidelines requirements' do
            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
          end

          it 'false if membership payment made and it HAS expired' do
            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user

            start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
            create(:membership_fee_payment,
                   :successful,
                   user: approved_and_paid,
                   start_date: start_date,
                   expire_date: expire_date)

            travel_to(expire_date + 1.day) do
              expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
            end
          end

          it 'false if membership payment not made' do
            expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
          end
        end
      end

      context 'does not have an approved application: always false' do

        context 'membership guidelines ARE agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true) }

          ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|

            context "app is #{app_state}" do

              it "false if membership payment made (and it has not expired)" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_user = unapproved_app.user
                start_date, expire_date = User.next_membership_payment_dates(unapproved_user.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_user,
                       start_date: start_date,
                       expire_date: expire_date)

                expect(subject.requirements_met?({ user: unapproved_user })).to be_falsey
              end

              it "false if membership payment made and it HAS expired" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_and_paid = unapproved_app.user

                start_date, expire_date = User.next_membership_payment_dates(unapproved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                travel_to(expire_date + 1.day) do
                  expect(subject.requirements_met?({ user: unapproved_and_paid })).to be_falsey
                end
              end

              it "false if membership payment not made" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_applicant = unapproved_app.user
                expect(subject.requirements_met?({ user: unapproved_applicant })).to be_falsey
              end
            end
          end
        end
      end
    end
  end
end
