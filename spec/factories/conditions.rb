FactoryBot.define do

  factory :condition do
    class_name { 'MyString' }
    timing { ConditionSchedule.default_schedule }
    config { {} }
  end

end
