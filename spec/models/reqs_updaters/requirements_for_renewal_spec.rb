require 'rails_helper'

RSpec.describe RequirementsForRenewal, type: :model do

  before(:each) do
    # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
    # if a ShfApplication is accepted.
    allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
  end

  let(:subject) { RequirementsForRenewal }
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


  describe '.requirements_met?' do
    it 'checks if all non-payment requirements are met' do
      u = build(:user)
      expect(subject).to receive(:requirements_excluding_payments_met?).with(u)
      subject.requirements_met?(user: u)
    end

    it 'checks if all payment requirements are met' do
      u = build(:user)
      allow(subject).to receive(:requirements_excluding_payments_met?)
                          .with(u)
                          .and_return(true)
      expect(subject).to receive(:payment_requirements_met?).with(u)
      subject.requirements_met?(user: u)
    end
  end


  describe '.requirements_excluding_payments_met?' do
    it 'all requirements checked and && together' do
      allow(subject).to receive(:max_days_can_still_renew).and_return(10)

      expect(user).to receive(:has_approved_shf_application?)
                        .and_return(true)
      expect(subject).to receive(:membership_guidelines_checklist_done?)
                           .and_return(true)
      expect(subject).to receive(:doc_uploaded_during_this_membership_term?)
                           .with(user)
                           .and_return(true)
      expect(user).to receive(:can_renew_today?)
                        .and_return(true)

      expect(subject.requirements_excluding_payments_met?(user)).to be_truthy
    end
  end


  describe '.doc_uploaded_during_this_membership_term?' do

    it 'queries the user to see if a doc has been uploaded on or after the term start' do
      expect(user).to receive(:file_uploaded_during_this_membership_term?)
                          .and_return(true)
      expect(subject.doc_uploaded_during_this_membership_term?(user)).to be_truthy
    end

    it 'no docs uploaded' do
      expect(subject.doc_uploaded_during_this_membership_term?(user)).to be_falsey
    end
  end


  describe '.max_days_can_still_renew' do
    it 'gets the membership_expired_grace_period from the Application Configuration' do
      expect(AdminOnly::AppConfiguration.config_to_use).to receive(:membership_expired_grace_period).and_return(5)
      described_class.max_days_can_still_renew
    end
  end


  describe '.payment_requirements_met?' do

    it 'true if a payment has been made and the expiration date is in the future' do
      u = build(:user)
      expect(u).to receive(:payments_current?).and_return(true)
      expect(subject.payment_requirements_met?(u)).to be_truthy
    end

    it 'false if no payments have been made' do
      u = build(:user)
      expect(subject.payment_requirements_met?(u)).to be_falsey
    end
  end


  # ------------------------------------------------------------------------------------------


  describe 'Integration tests' do
    let(:member) { build(:member_with_membership_app) }

    describe '.requirements_met?' do
      before(:each) { allow(User).to receive(:days_can_renew_early).and_return(5) }

      it 'always false if has never made a payment' do
        approved_app = create(:shf_application, :accepted)
        expect(subject.requirements_met?({ user: approved_app.user })).to be_falsey
      end


      context 'has approved application' do

        let(:approved_applicant) do
          approved_app = create(:shf_application, :accepted)
          approved_app.user
        end

        context 'membership guidelines ARE agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true) }

          context 'file has been uploaded during this membership term' do
            before(:each) { allow(described_class).to receive(:doc_uploaded_during_this_membership_term?).and_return(true) }

            context 'membership has not expired' do

              it 'true if not too early to renew' do
                another_approved_app = create(:shf_application, :accepted)
                approved_and_paid = another_approved_app.user

                start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: approved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                travel_to(expire_date - 3) do
                  expect(approved_and_paid.can_renew_today?).to be_truthy
                  expect(approved_and_paid.membership_guidelines_checklist_done?).to be_truthy
                  expect(subject.doc_uploaded_during_this_membership_term?(approved_and_paid)).to be_truthy

                  expect(subject.requirements_met?({ user: approved_and_paid })).to be_truthy
                end
              end

              it 'false if too early to renew' do
                another_approved_app = create(:shf_application, :accepted)
                approved_and_paid = another_approved_app.user

                start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: approved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                travel_to(expire_date - 7) do
                  expect(approved_and_paid.can_renew_today?).to be_falsey
                  expect(approved_and_paid.membership_guidelines_checklist_done?).to be_truthy
                  expect(subject.doc_uploaded_during_this_membership_term?(approved_and_paid)).to be_truthy

                  expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
                end
              end
            end

            context 'membership has expired' do

              it 'false if membership payment made and still in grace period' do
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
            end

            it 'false if membership payment not made' do
              expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
            end
          end

          context 'no file uploaded during this membership term' do
            it 'always false' do
              allow(described_class).to receive(:doc_uploaded_during_this_membership_term?)
                                          .and_return(false)

              another_approved_app = create(:shf_application, :accepted)
              approved_and_paid = another_approved_app.user

              start_date, expire_date = User.next_membership_payment_dates(approved_and_paid.id)
              create(:membership_fee_payment,
                     :successful,
                     user: approved_and_paid,
                     start_date: start_date,
                     expire_date: expire_date)

              travel_to(expire_date - 3) do
                expect(approved_and_paid.can_renew_today?).to be_truthy
                expect(approved_and_paid.membership_guidelines_checklist_done?).to be_truthy
                expect(subject.doc_uploaded_during_this_membership_term?(approved_and_paid)).to be_falsey

                expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
              end
            end
          end

        end

        context 'membership guidelines NOT agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false) }

          it 'always false' do
            another_approved_app = create(:shf_application, :accepted)
            approved_and_paid = another_approved_app.user
            expect(subject.requirements_met?(user: approved_and_paid)).to be_falsey
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
