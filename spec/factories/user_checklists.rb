FactoryBot.define do

  factory :user_checklist do
    association :checklist
    association :user
  end

end
