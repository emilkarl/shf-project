KLARNA_CHECKOUT_URL = ENV['SHF_KLARNA_CHECKOUT_URL']
KLARNA_ORDER_MGMT_URL = ENV['SHF_KLARNA_ORDER_MGMT_URL']

if Rails.env.production?
  KLARNA_API_AUTH_USERNAME  = ENV['SHF_KLARNA_API_AUTH_USERNAME']
  KLARNA_API_AUTH_PASSWORD  = ENV['SHF_KLARNA_API_AUTH_PASSWORD']
else
  KLARNA_API_AUTH_USERNAME  = ENV['SHF_KLARNA_API_AUTH_USERNAME_DEV']
  KLARNA_API_AUTH_PASSWORD  = ENV['SHF_KLARNA_API_AUTH_PASSWORD_DEV']
end

SHF_MEMBER_FEE   = 30000  # unit == one hundredth krona @fixme should get this from AppConfig @see https://www.pivotaltracker.com/story/show/181890844
SHF_BRANDING_FEE = 50000  # unit == one hundredth krona @fixme should get this from AppConfig @see https://www.pivotaltracker.com/story/show/181890844

SHF_WEBHOOK_HOST = ENV['SHF_DEV_WEBHOOK_HOST']
