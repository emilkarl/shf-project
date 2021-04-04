require 'rails_helper'

RSpec.describe Memberships::NewIndividualMembershipActions do

  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }
  let(:new_membership) { create(:membership) }
  let(:given_user) { new_membership.user }


  describe '.other_keyword_args_valid?' do

    it 'true if has key first_day: and the value is not nil' do
      expect(described_class.other_keyword_args_valid?(first_day: Date.current)).to be_truthy
    end

    it 'false if does not have key first_day: or if value is nil' do
      expect(described_class.other_keyword_args_valid?(first_day: nil)).to be_falsey
      expect(described_class.other_keyword_args_valid?(anything_else: 'blorf')).to be_falsey
      expect(described_class.other_keyword_args_valid?({})).to be_falsey
    end
  end


  describe '.accomplish_actions' do
    let(:mock_membership) { double('Membership', set_first_and_last_day: true) }

    it 'creates a new membership for the user, first_day = the given first day' do
      allow(given_user).to receive(:update!)

      expect(Membership).to receive(:last_day_from_first).and_return(Date.current + 1.year)
      expect(Membership).to receive(:create!)
                              .with(user: given_user,
                                    first_day: Date.current, last_day: Date.current + 1.year)
                              .and_return(mock_membership)
      described_class.accomplish_actions(given_user, send_email: false, first_day: Date.current)
    end

    it 'updates the user with a new membership number' do
      allow(Membership).to receive(:create!)
                              .and_return(mock_membership)
      allow(mock_membership).to receive(:set_first_day_and_last)

      expect(given_user).to receive(:update!).with(member: true, membership_number: anything)

      described_class.accomplish_actions(given_user, send_email: false, first_day: Date.current)
    end

    context 'send_email is true' do
      before(:each) do
        allow(Membership).to receive(:create!)
                               .and_return(mock_membership)
        allow(mock_membership).to receive(:set_first_day_and_last)
        allow(given_user).to receive(:update!)
      end

      it 'delivers a membership_granted email to the user' do
        allow(described_class).to receive(:email_admin_if_first_membership_with_good_co)

        expect(MemberMailer).to receive(:membership_granted)
                                 .with(given_user).and_return(mock_email_msg)
        described_class.accomplish_actions(given_user, send_email: true, first_day: Date.current)
      end

      it 'calls AdminAlerter with the user and deliver_email: the send_email status' do
        allow(MemberMailer).to receive(:membership_granted).and_return(mock_email_msg)

        expect(AdminAlerter.instance).to receive(:new_membership_granted).with(given_user, deliver_email: true)
        described_class.accomplish_actions(given_user, send_email: true, first_day: Date.current)
      end
    end
  end


  describe '.email_admin_if_first_membership_with_good_co' do

    context 'is the first membership' do
      before(:each) { allow(new_membership).to receive(:first_membership?).and_return(true) }

      context 'user belongs to a company in good standing' do
        before(:each) { allow(given_user).to receive(:has_company_in_good_standing?).and_return(true) }

        it 'delivers new_membership_granted_co_hbrand_paid to the Admin' do
          expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid)
                                   .with(given_user).and_return(mock_email_msg)
          described_class.email_admin_if_first_membership_with_good_co(new_membership)
        end
      end
    end

    it 'does nothing if is not the first membership' do
       allow(new_membership).to receive(:first_membership?).and_return(false)

       expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
       described_class.email_admin_if_first_membership_with_good_co(new_membership)
    end

    it 'does nothing if the user does not belong to a company in good standing' do
      allow(new_membership).to receive(:first_membership?).and_return(true)
      allow(given_user).to receive(:has_company_in_good_standing?).and_return(false)

      expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
      described_class.email_admin_if_first_membership_with_good_co(new_membership)
    end
  end

  describe '.log_message_success' do
    it 'New membership granted' do
      expect(described_class.log_message_success).to eq('New membership granted')
    end
  end

end
