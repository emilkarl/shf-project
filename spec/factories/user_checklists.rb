FactoryBot.define do

  factory :user_checklist do

    association user
    association checklist
    date_completed { "2019-12-04 12:34:16" }
  end

end
