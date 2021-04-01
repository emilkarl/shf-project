# Steps for viewing membership status, changing it

Then(/I should be a member/) do
  @user.reload  # ensure the info is up to date
  # expect(@user.member).to be_truthy, "Expected user ''#{@user.full_name}'' to be a member, but is not. Membership expiration date is #{@user.membership_expire_date}"
  #  expect(@user.membership_current?).to be_truthy, "Expected user ''#{@user.full_name}'' to be a member, but is not. Membership expiration date is #{@user.membership_expire_date}"
  expect(@user.member_in_good_standing?).to be_truthy, "Expected user ''#{@user.full_name}'' to be a member in good standing, but is not. Membership expiration date is #{@user.membership_expire_date}"
end

Then(/I should not be a member/) do
  @user.reload
  # expect(@user.member).not_to be_truthy
  # expect(@user.membership_current?).not_to be_truthy, "Expected user ''#{@user.full_name}'' NOT to be a member, but is. Membership expiration date is #{@user.membership_expire_date}"
  expect(@user.member_in_good_standing?).not_to be_truthy, "Expected user ''#{@user.full_name}'' NOT to be a member in good standing, but is. Membership expiration date is #{@user.membership_expire_date}"
end

And("My membership expiration date is {date}") do |date|
  expect(@user.membership_expire_date).to eq date
end
