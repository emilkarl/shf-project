# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'


class MemberMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def membership_granted
    approved_app = ShfApplication.where(state: :accepted).first
    check_co_name(approved_app.companies.first)
    MemberMailer.membership_granted(approved_app.user)
  end


  def membership_expiration_reminder
    member = User.current_member.first
    MemberMailer.membership_expiration_reminder(member)
  end


  def h_branding_fee_will_expire
    licensed_co = Company.branding_licensed.first
    co_member = licensed_co.users.last
    check_co_name(licensed_co)
    MemberMailer.h_branding_fee_will_expire(licensed_co, co_member)
  end


  # Previewing can cause this to be called twice:  once to create the header,
  # and again for the mail body.
  # So if the user already exists, use it, else create a new one
  def h_branding_fee_past_due

    new_email = unique_email

    unless (new_approved_user = User.find_by(email: new_email))
      new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    end
    new_co = new_approved_user.shf_application.companies.first
    check_co_name(new_co)
    MemberMailer.h_branding_fee_past_due(new_co, new_approved_user)
  end


  def membership_lapsed
    if User.in_grace_period.count == 0
      # take a current member and put them into the grace period
      lapsed_member = User.current_member.second
      current_membership = lapsed_member.memberships_manager.most_recent_membership(lapsed_member)
      current_membership.update(last_day: Date.current - 3)
      lapsed_member.start_grace_period!
    else
      lapsed_member = User.in_grace_period.first
    end

    MemberMailer.membership_lapsed(lapsed_member)
  end


  def company_info_incomplete

    approved_app = ShfApplication.where(state: :accepted).first
    approved_user = approved_app.user
    incomplete_co = approved_app.companies.first
    incomplete_co.update(name: '')
    incomplete_co.addresses.first.update(region: nil)
    check_co_name(incomplete_co)

    MemberMailer.company_info_incomplete(incomplete_co, approved_user)
  end


  def app_no_uploaded_files

    # create a new user with a brand new application (that has no uploaded files)
    new_email = "sussh-#{DateTime.now.strftime('%Q')}@example.com"

    new_approved_user = User.create(first_name: 'Suss',
                                    last_name: 'Hundapor',
                                    password: 'whatever',
                                    email: new_email,
                                    member_photo: nil,
    )
    ShfApplication.new(user: new_approved_user)

    MemberMailer.app_no_uploaded_files new_approved_user

  ensure
    User.delete(new_approved_user.id) unless new_approved_user.nil?
  end


  def first_membership_fee_owed
    # Create a new user with an approved application but no payments

    new_email = unique_email

    unless (new_approved_user = User.find_by(email: new_email))
      new_approved_user = FactoryBot.create(:user_with_membership_app, email: new_email, password: 'whatever')
    end
    shf_app = new_approved_user.shf_application
    shf_app.update(when_approved: Time.zone.now)
    shf_app.update(state: 'accepted')

    MemberMailer.first_membership_fee_owed(new_approved_user)
  end


  def membership_renewed
    # Select a current member
    member_to_renew = User.current_member.sort_by(&:membership_expire_date).first

    unless member_to_renew.companies.detect { |co| !co.information_complete? }
      incomplete_company = FactoryBot.create(:company, name: 'Incomplete (no region)')
      incomplete_company.addresses.first.update(region: nil)
      member_to_renew.shf_application.companies << incomplete_company
    end

    unless member_to_renew.companies.detect { |co| co.payment_term_expired? }
      expired_company = FactoryBot.create(:company, name: 'Expired')
      # TODO when Company uses Membership, then change this to (from using payments)
      FactoryBot.create(:h_branding_fee_payment, user: member_to_renew,
                        company: expired_company,
                        expire_date: Date.current - 1.day )
      member_to_renew.shf_application.companies << expired_company
    end

    unless member_to_renew.companies.detect { |co| co.payment_term_expired? && !co.information_complete? }
      expired_and_incomplete_company = FactoryBot.create(:company, name: 'Expired and Incomplete Co.')
      # TODO when Company uses Membership, then change this to (from using payments)
      FactoryBot.create(:h_branding_fee_payment, user: member_to_renew,
                        company: expired_and_incomplete_company,
                        expire_date: Date.current - 1.day )
      expired_and_incomplete_company.addresses.first.update(region: nil)
      member_to_renew.shf_application.companies << expired_and_incomplete_company
    end

    MemberMailer.membership_renewed(member_to_renew)
  end


private


  # create a unique email address based on the Time right now
  def unique_email
    "user-#{Time.now.to_i}@example.com"
  end


  # Sometimes if company is created for the preview, there is no name.
  # Check this and if the company name is blank, put one it.
  def check_co_name(company)
    company.update(name: 'Some Company AB') if company.name.blank?
  end

end
