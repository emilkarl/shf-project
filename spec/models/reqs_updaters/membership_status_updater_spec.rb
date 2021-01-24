require 'rails_helper'

require 'shared_context/users'

RSpec.describe MembershipStatusUpdater, type: :model do

  let(:subject) { MembershipStatusUpdater.instance }

  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  let(:payment_date_2017) { Time.zone.local(2017, 10, 1) }
  let(:payment_date_2018) { Time.zone.local(2018, 11, 21) }

  let(:user) { build(:user) }
  let(:user_app_approved) do
    u = create(:user)
    create( :shf_application,
            :accepted,
            user: u, )
    u
  end

  let(:payment_user_approved_app) do
    start_date, expire_date = User.next_membership_payment_dates(user_app_approved.id)

    create(:membership_fee_payment,
           :successful,
           user: user_app_approved,
           start_date: start_date,
           expire_date: expire_date)
  end


  let(:paid_member) { create(:member_with_membership_app) }

  let(:shf_app) { create(:shf_application) }


  it '.update_requirements_checker is RequirementsForMembership' do
    expect(described_class.update_requirements_checker).to be(RequirementsForMembership)
  end

  it '.revoke_requirements_checker is RequirementsForRevokingMembership' do
    expect(described_class.revoke_requirements_checker).to be(RequirementsForRevokingMembership)
  end


  it 'shf_application_updated calls check_user_and_log with a message the shows the start up the updating process' do
    shf_app_updated = build(:shf_application, user: build(:user))

    expect(subject).to receive(:check_user_and_log).with(shf_app_updated.user,
                                                         shf_app_updated,
                                                         subject.logmsg_user_updated,
                                                         subject.logmsg_user_updated_start)
    subject.shf_application_updated(shf_app_updated)
  end


  it 'payment_made calls check_user_and_log with a message that a payment was made and that the membership status has finished being checked' do
    payment_for_not_expired_paid_member = build(:payment,
                                                 user: build(:user),
                                                 start_date: Date.current,
                                                 expire_date: Date.current + 1.day)

    expect(subject).to receive(:check_user_and_log).with(payment_for_not_expired_paid_member.user,
                                                         payment_for_not_expired_paid_member,
                                                         subject.logmsg_payment_made,
                                                         subject.logmsg_payment_made_finished_checking)
    subject.payment_made(payment_for_not_expired_paid_member)
  end


  it 'user_updated calls check_user_and_log with a message that the user was updated' do
    expect(subject).to receive(:check_user_and_log).with(user, user,
                                                         subject.logmsg_user_updated,
                                                         subject.logmsg_user_updated)
    subject.user_updated(user)
  end


  it 'revoke_user_membership calls check_user_and_log with a message that membership was revoked' do
    expect(subject).to receive(:check_user_and_log).with(user, user,
                                                         subject.logmsg_user_updated,
                                                         subject.logmsg_membership_revoked)
    subject.revoke_user_membership(user)
  end


  describe 'update_action' do

    # Note - since this is a private method, we can only do unit testing of it
    # with RSpec if we explicitly :send the message to the subject

    context 'already a member' do
      it 'does nothing' do
        member = build(:user)
        allow(member).to receive(:membership_status).and_return(:current)

        expect(subject).not_to receive(:renew_membership).with(member, anything)
        expect(subject).not_to receive(:grant_membership).with(member, anything)
        subject.send(:update_action, {user: member}) # this is equivalent to subject.update_action(new_member)
      end
    end

    context 'in the grace period (renewal overdue)' do
      it 'renews' do
        in_grace_period_member = build(:user)
        allow(in_grace_period_member).to receive(:membership_status).and_return(:in_grace_period)

        expect(subject).to receive(:renew_membership).with(in_grace_period_member, anything)
        subject.send(:update_action, {user: in_grace_period_member}) # this is equivalent to subject.update_action(new_member)
      end
    end

    context 'former member' do
      it 'grants membership' do
        former_member = build(:user)
        allow(former_member).to receive(:membership_status).and_return(:past_member)

        expect(subject).to receive(:grant_membership).with(former_member, anything)
        subject.send(:update_action, {user: former_member})
      end
    end

    context 'not a member' do
      it 'grants membership' do
        not_a_member = build(:user)
        allow(not_a_member).to receive(:membership_status).and_return(:not_a_member)

        expect(subject).to receive(:grant_membership).with(not_a_member, anything)
        subject.send(:update_action, {user: not_a_member})
      end
    end


    it 'sends emails out by default' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:membership_status).and_return(:not_a_member)

      expect(subject).to receive(:grant_membership).with(not_a_member, true)
      subject.send(:update_action, {user: not_a_member})
    end

    it 'send_email: true sends email to the member' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:membership_status).and_return(:not_a_member)

      expect(subject).to receive(:grant_membership).with(not_a_member, true)
      subject.send(:update_action, {user: not_a_member, send_email: true})
    end

    it 'send_email: false does not send email to the member' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:membership_status).and_return(:not_a_member)

      expect(subject).to receive(:grant_membership).with(not_a_member, false)
      subject.send(:update_action, {user: not_a_member, send_email: false})
    end
  end


  describe 'revoke_update_action' do

    # Note - since this is a private method, we can only do unit testing of it
    # with RSpec if we explicitly :send the message to the subject

    it 'user.member? is false afterwards' do
      member = build(:member_with_expiration_date)
      allow(member).to receive(:membership_status).and_return(:current)

      expect(member.member?).to be_truthy
      subject.send(:revoke_update_action, {user: member}) # this is equivalent to subject.revoke_update_action({user: user})
      expect(member.member?).to be_falsey
    end

  end


  describe 'grant membership' do

    before(:each) do
      # mock the MemberMailer so we don't try to send emails
      allow(MemberMailer).to receive(:membership_granted).and_return(double('MemberMailer', deliver: true))
    end


    it 'user.member? is true afterwards' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:issue_membership_number).and_return(1001)

      expect(not_a_member.member?).to be_falsey
      subject.send(:grant_membership, not_a_member, false) # do not send email
      expect(not_a_member.member?).to be_truthy
    end


    describe 'send the Admin an email' do
      let(:never_a_member) do
        u = build(:user)
        allow(u).to receive(:issue_membership_number).and_return(1001)
        allow(u).to receive(:member).and_return(false)
        allow(u).to receive(:membership_number).and_return(nil)
        allow(u).to receive(:update).with(member: true, membership_number: 1001)
        u
      end

      context 'this is the first membership for the user' do
        before(:each) { allow(subject).to receive(:first_membership?).and_return(true) }

        context 'the user belongs to at least one company' do
          let(:co_complete_with_current_branding_license) { build(:company) }
          before(:each) { allow(never_a_member).to receive(:companies).and_return([co_complete_with_current_branding_license]) }

          it 'email sent if at least one company is in good standing' do
            allow(co_complete_with_current_branding_license).to receive(:in_good_standing?).and_return(true)
            expect(AdminMailer).to receive(:new_membership_granted_co_hbrand_paid).and_return(double('AdminMailer', deliver: true))
            subject.send(:grant_membership, never_a_member, true)
          end

          it 'no email sent if no companies are in good standing' do
            allow(co_complete_with_current_branding_license).to receive(:in_good_standing?).and_return(false)
            expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
            subject.send(:grant_membership, never_a_member, true)
          end
        end

        it 'no email sent: the user does not belong to any companies' do
          allow(never_a_member).to receive(:companies).and_return([])
          expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
          subject.send(:grant_membership, never_a_member, true)
        end
      end

      it 'no email sent: this is not the first membership for the user' do
        allow(subject).to receive(:first_membership?).and_return(false)
        expect(AdminMailer).not_to receive(:new_membership_granted_co_hbrand_paid)
        subject.send(:grant_membership, never_a_member, true)
      end
    end


    it 'logs a message that membership was granted to the user' do
      not_a_member = build(:user)
      allow(not_a_member).to receive(:issue_membership_number).and_return(1001)
      allow(not_a_member).to receive(:update).with(member: true, membership_number: 1001)

      expect(mock_log).to receive(:record).with(:info, /#{subject.logmsg_membership_granted}/)
      subject.send(:grant_membership, not_a_member, false) # do not send email
    end
  end


  describe 'renew_membership' do

    context 'send email' do
      it 'sends the membership renewed email to the user' do
        u = build(:user)
        allow(mock_log).to receive(:record)

        expect(MemberMailer).to receive(:membership_renewed)
                                  .with(u)
                                  .and_return(double('MemberMailer', deliver: true))
        subject.send(:renew_membership, u, true)
      end
    end

    context 'do not send email' do
      it 'no email is sent' do
        allow(mock_log).to receive(:record)
        expect(MemberMailer).not_to receive(:membership_renewed)
        subject.send(:renew_membership, build(:user), false)
      end
    end

    it 'logs a message that the membership was renewed' do
      expect(mock_log).to receive(:record)
                            .with(:info, /#{subject.logmsg_membership_renewed}/)
      subject.send(:renew_membership, build(:user), false)
    end
  end


  describe 'check_user_and_log' do

    it 'checks the requirements and acts' do
      u = build(:user)
      allow(mock_log).to receive(:record)
      expect(subject).to receive(:check_requirements_and_act).with(user: u)
      subject.send(:check_user_and_log, u, 'blorf', 'action', 'testing that checks the reqiurements and acts happens')
    end

    it 'logs the reason that the check happened and who sent the action to check the user' do
      u = build(:user)
      allow(subject).to receive(:check_requirements_and_act).with(user: u)
      expect(mock_log).to receive(:record)
                            .with(:info,
                                  'testing that checks the reqiurements and acts happens: "blorf"')
      subject.send(:check_user_and_log, u, 'blorf', 'action', 'testing that checks the reqiurements and acts happens')
    end
  end


  describe 'first_membership?(previous_membership_status, previous_membership_number)' do

    context 'previous membership status = true' do

      it 'false if previous membership number not nil' do
        expect(subject.send(:first_membership?, true, 'blorf') ).to be_falsey
      end

      it  'false if previous membership number is nil'  do
        expect(subject.send(:first_membership?, true, nil) ).to be_falsey
        expect(subject.send(:first_membership?, true) ).to be_falsey
      end
    end

    context 'previous membership status = false' do

      it 'false if previous membership number not nil' do
        expect(subject.send(:first_membership?, false, '') ).to be_falsey
      end

      it 'true if previous membership number is nil'  do
        expect(subject.send(:first_membership?, false, nil) ).to be_truthy
        expect(subject.send(:first_membership?, false) ).to be_truthy
      end
    end

  end

end
