# Steps dealing with AdminOnly::AppConfiguration


# This step can be used to make sure that an actual valid
# Application Configuration (AdminOnly::AppConfiguration)
# is used.  A valid AppConfiguration is created (all required data is there)
# and all of the methods are called. None of the methods are stubbed.
# This means that Paperclip is likely to be called because the attachments
# are referenced (e.g. the "proof of membership" or some other attached image).
# Because this is a new AppConfiguration, Paperclip will need to create the
# file information for each attachment: the content type, any other image sizes, etc.
# This involves both file I/O, which is slow, and system calls to external
# programs that Paperclip needs to use.
# Thus most of the time tests can and should work with a _mocked_
# AppConfiguration which stubs methods and so none of the Paperclip stuff is
# ever called.  (This is set up in the *Before* block in features/support/env.rb )
# But when the feature needs to work with any of the actual AppConfiguration,
# this step should be used.
#
# @example
# Feature: A member pays their membership fee and is approved
#
#   Background:
#     Given the App Configuration is not mocked and is seeded
#
#     Given the following users exist:
#     ...
#
#   Scenario: .....
#
And(/^the App Configuration is not mocked and is seeded$/) do

  # If this has been stubbed (e.g. to use MockAppConfig), unstub it
  allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_call_original

  AdminOnly::AppConfiguration.create(email_admin_new_app_received_enabled: false)
end
