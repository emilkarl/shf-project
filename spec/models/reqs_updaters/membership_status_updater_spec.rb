require 'rails_helper'

require 'shared_context/users'

RSpec.describe MembershipStatusUpdater, type: :model do

  let(:subject) { MembershipStatusUpdater.instance }

  let(:mock_log) { instance_double("ActivityLogger") }
  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }

  before(:each) do
    allow(MemberMailer).to receive(:membership_granted)
                              .and_return(mock_email_msg)
    allow(MemberMailer).to receive(:membership_renewed)
                             .and_return(mock_email_msg)

    allow_any_instance_of(ApplicationMailer).to receive(:mail).and_return(mock_email_msg)
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


  it 'shf_application_updated calls update_membership_status with a message that the app was updated' do
    shf_app_updated = build(:shf_application, user: build(:user))

    expect(subject).to receive(:update_membership_status).with(shf_app_updated.user,
                                                               shf_app_updated,
                                                               subject.logmsg_app_updated)
    subject.shf_application_updated(shf_app_updated)
  end


  it 'payment_made calls update_membership_status with a message that a payment was made' do
    payment_for_not_expired_paid_member = build(:payment,
                                                user: build(:user),
                                                start_date: Date.current,
                                                expire_date: Date.current + 1.day)

    expect(subject).to receive(:update_membership_status).with(payment_for_not_expired_paid_member.user,
                                                               payment_for_not_expired_paid_member,
                                                               subject.logmsg_payment_made)
    subject.payment_made(payment_for_not_expired_paid_member)
  end


  it 'user_updated calls update_membership_status with a message that the user was updated' do
    expect(subject).to receive(:update_membership_status).with(user,
                                                               user,
                                                               subject.logmsg_user_updated)
    subject.user_updated(user)
  end



  describe 'update_membership_status' do

    # ------------------------------------------------------------------
    # Shared examples:
    #   all assume that given_user is defined

    shared_examples 'potentially can become a member' do
      context 'satisfies all requirements for becoming a member' do
        before(:each) do
          allow(RequirementsForMembership).to receive(:satisfied?)
                                                .with(user: given_user)
                                                .and_return(true)
        end

        it 'starts a new membership and logs that the membership status was changed' do
          expect(given_user).to receive(:start_membership!).and_call_original
          expect(mock_log).to receive(:info).with("update_membership_status for #{given_user.inspect}")

          subject.update_membership_status(given_user)
        end
      end

      context 'does not satisfy all the requirements for becoming a member' do
        before(:each) do
          allow(RequirementsForMembership).to receive(:satisfied?)
                                                .with(user: given_user)
                                                .and_return(false)
        end

        it 'does not start a new membership' do
          expect(given_user).not_to receive(:start_membership!)
          subject.update_membership_status(given_user)
        end
      end
    end


    # Assumes given_user is defined
    shared_examples 'potentially can renew' do

      context 'satisfies all requirements for renewing' do
        before(:each) do
          allow(RequirementsForRenewal).to receive(:satisfied?)
                                             .with(user: given_user)
                                             .and_return(true)
        end

        it 'renews membership and logs that the membership status was updated' do
          expect(given_user).to receive(:renew!)
          expect(mock_log).to receive(:info).with("update_membership_status for #{given_user.inspect}")

          subject.update_membership_status(given_user)
        end
      end

      context 'does not satisfy all requirements for renewing' do
        before(:each) do
          allow(RequirementsForRenewal).to receive(:satisfied?)
                                             .with(user: given_user)
                                             .and_return(false)
        end

        it 'does not renew membership' do
          expect(given_user).not_to receive(:renew!)
          subject.update_membership_status(given_user)
        end
      end
    end
    # ------------------------------------------------------------------


    context 'is not a member' do
      it_should_behave_like 'potentially can become a member' do
        let(:given_user) do
          user = build(:user)
          user.membership_status = :not_a_member
          user
        end
      end
    end


    context 'is a current member' do
      let(:user) do
        u = build(:member_with_expiration_date, expiration_date: (Date.current + 1.day))
        u.membership_status = :current_member
        u
      end


      it_should_behave_like 'potentially can renew' do
        let(:given_user) do
          user = build(:member_with_expiration_date, expiration_date: (Date.current + 1.day))
          user.membership_status = :current_member
          user
        end
      end

      context 'is now in the renewal grace period' do
        before(:each) do
          allow(user).to receive(:membership_expired_in_grace_period?).and_return(true)
        end

        it 'starts the grace period and logs that the membership status has changed' do
          allow(RequirementsForRenewal).to receive(:satisfied?).and_return(false)

          expect(user).to receive(:start_grace_period!).and_call_original
          expect(mock_log).to receive(:info).with("update_membership_status for #{user.inspect}")

          subject.update_membership_status(user)
        end

        it 'checks to see if the requirements for renewal are satisfied' do
          expect(RequirementsForRenewal).to receive(:satisfied?).and_return(true)

          subject.update_membership_status(user)
        end
      end


      context 'is past the last day of the renwal grace period' do
        before(:each) do
          allow(user).to receive(:membership_expired_in_grace_period?)
                           .and_return(false)
          allow(user).to receive(:membership_past_grace_period_end?)
                           .and_return(true)
        end

        it 'starts the grace period AND then becomes a former member and logs changes' do
          allow(RequirementsForRenewal).to receive(:satisfied?)
                                             .and_return(false)

          expect(user).to receive(:start_grace_period!)
          expect(user).to receive(:make_former_member!)

          # called once when the status is initialzed for the test,
          #   once in start_grace_period!
          #   and once in make_former_member!
          expect(user).to receive(:membership_changed_info).exactly(3).times.
            and_call_original
          expect(mock_log).to receive(:info).twice.with("#{user.membership_changed_info}")

          subject.update_membership_status(user)
        end

        it 'cannot renew (will not satisfy the requirements for renewal)' do
          allow(user).to receive(:start_grace_period!)
          allow(user).to receive(:make_former_member!)

          expect(RequirementsForRenewal).to receive(:satisfied?)
                                              .and_return(false)
          subject.update_membership_status(user)
        end
      end
    end


    context 'is in the renewal grace period' do

      context 'date is NOT past (>) the last day of the renewal grace period' do
        it_should_behave_like 'potentially can renew' do
          let(:given_user) do
            user = build(:user, membership_status: :in_grace_period)
            allow(user).to receive(:membership_past_grace_period_end?)
                             .and_return(false)
            user
          end
        end
      end

      context 'date is now past (>) the last day of the renewal grace period' do
        it 'becomes a former member' do
          user = build(:user)
          user.membership_status = :in_grace_period

          expect(user).to receive(:membership_past_grace_period_end?)
                            .and_return(true)
          expect(user).to receive(:make_former_member!)
          subject.update_membership_status(user)
        end
      end
    end


    context 'is a former member' do
      it_should_behave_like 'potentially can become a member' do
        let(:given_user) do
          user = build(:user)
          user.membership_status = :former_member
          user
        end
      end
    end
  end


  it 'send_email default is true' do
    expect(subject.send_email).to be_truthy
  end
  end
