RSpec.shared_context 'create users' do

  let(:user) { create(:user) }

  let(:member_paid_up) do
    user = build(:member_with_membership_app)
    user.payments << create(:membership_fee_payment)
    user.save!
    user
  end

  let(:member_expired) do
    user = build(:member_with_membership_app)
    user.payments << create(:expired_membership_fee_payment)
    user.save!
    user
  end


  THIS_YEAR = 2018

  let(:jul_1) { Time.zone.local(THIS_YEAR, 7, 1) }
  let(:nov_29) { Time.zone.local(THIS_YEAR, 11, 29) }
  let(:nov_30) { Time.zone.local(THIS_YEAR, 11, 30) }
  let(:dec_1) { Time.zone.local(THIS_YEAR, 12, 1) }
  let(:dec_2) { Time.zone.local(THIS_YEAR, 12, 2) }
  let(:dec_3) { Time.zone.local(THIS_YEAR, 12, 3) }

  let(:nov_29_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 29) }
  let(:nov_30_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 30) }
  let(:nov_29_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 29) }
  let(:nov_30_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 30) }

  let(:lastyear_dec_2) { Time.zone.local(THIS_YEAR - 1, 12, 2) }
  let(:lastyear_dec_8) { Time.zone.local(THIS_YEAR - 1, 12, 8) }
  let(:lastyear_dec_9) { Time.zone.local(THIS_YEAR - 1, 12, 9) }

  let(:jan_30) { Time.zone.local(THIS_YEAR, 1, 30) }
  let(:feb_1) { Time.zone.local(THIS_YEAR, 2, 1) }
  let(:feb_2) { Time.zone.local(THIS_YEAR, 2, 2) }
  let(:feb_3) { Time.zone.local(THIS_YEAR, 2, 3) }


  let(:user_pays_every_nov30) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(nov_30_last_year) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: User.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: Company.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year branding')
    end

    Timecop.freeze(nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: User.expire_date_for_start_date(nov_30),
             notes:       'nov_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: Company.expire_date_for_start_date(nov_30),
             notes:       'nov_30 branding')
    end

    u
  end


  let(:user_paid_only_lastyear_dec_2) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_2) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: User.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 branding')
    end
    u
  end


  let(:user_paid_lastyear_nov_29) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(nov_29_last_year) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_29_last_year,
             expire_date: User.expire_date_for_start_date(nov_29_last_year),
             notes:       'nov_29_last_year membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_29_last_year,
             expire_date: Company.expire_date_for_start_date(nov_29_last_year),
             notes:       'nov_29_last_year branding')
    end
    u
  end


  let(:user_unsuccessful_this_year) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    # success on nov 30 last year
    Timecop.freeze(nov_30_last_year) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: User.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year success membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: Company.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year success branding')
    end

    # failed on nov 29
    Timecop.freeze(nov_29) do
      create(:membership_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: User.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) membership')
      create(:h_branding_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: Company.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) branding')
    end

    u
  end

  let(:company__unsuccessful_this_year) { user_unsuccessful_this_year.shf_application.companies.first }


  let(:user_no_payments)     { create(:user) }
  let(:company_no_payments)  { create(:company) }


  let(:user_membership_expires_EOD_jan29) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(jan_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_30,
             expire_date: User.expire_date_for_start_date(jan_30),
             notes:       'jan_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_30,
             expire_date: Company.expire_date_for_start_date(jan_30),
             notes:       'jan_30 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_feb1) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(feb_2) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_2,
             expire_date: User.expire_date_for_start_date(feb_2),
             notes:       'feb_2 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_2,
             expire_date: Company.expire_date_for_start_date(feb_2),
             notes:       'feb_2 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_feb2) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(feb_3) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_3,
             expire_date: User.expire_date_for_start_date(feb_3),
             notes:       'feb_3 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_3,
             expire_date: Company.expire_date_for_start_date(feb_3),
             notes:       'feb_3 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_dec7) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_8) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_8,
             expire_date: User.expire_date_for_start_date(lastyear_dec_8),
             notes:       'lastyear_dec_8 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_8,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_8),
             notes:       'lastyear_dec_8 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_dec8) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_9) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_9,
             expire_date: User.expire_date_for_start_date(lastyear_dec_9),
             notes:       'lastyear_dec_9 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_9,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_9),
             notes:       'lastyear_dec_9 branding')
    end

    u
  }

end
