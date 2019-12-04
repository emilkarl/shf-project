FactoryBot.define do

  factory :user_checklist_item do

    association :checklist_item
    association :user

    time_completed { nil }


    trait :completed  do
      time_completed { Time.zone.now }
    end

    trait :not_completed do
      time_completed { nil }
    end
  end

end
