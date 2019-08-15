FactoryBot.define do

  factory :condition_schedule do
    timing { :on }
  end


  trait :after do
    timing { :after }
  end

  trait :before do
    timing { :before }
  end

  trait :on  do
    timing { :on }
  end

  trait :every_day  do
    timing { :every_day }
  end

  trait :monthly do
    timing { :on_month_day }
  end

end
