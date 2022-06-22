FactoryBot.define do
  factory :business_category do
    name { "Business Category" }
    description { "business category description" }
    apply_qs_url { 'https://example.com/more-questions-for-application' }
  end
end
