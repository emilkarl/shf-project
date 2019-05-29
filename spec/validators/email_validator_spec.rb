require 'rails_helper'
require 'support/validator_helper'
include ValidatorHelper

RSpec.describe EmailValidator do
  let(:model) { ValidatorHelper.test_model_class }
  let(:record) { model.new }

  let(:error_msg) { I18n.t('errors.messages.invalid') }

  before(:each) do
    record.class_eval do
      validates :test_attr, email: true
    end
  end

  it 'adds error message when email is invalid' do
    record.test_attr = 'email.com'
    expect { record.valid? }
      .to change(record.errors, :messages).from({})
      .to a_hash_including(test_attr: [error_msg])

    record.errors.clear
    record.test_attr = 'email@.com'
    expect { record.valid? }
      .to change(record.errors, :messages).from({})
      .to a_hash_including(test_attr: [error_msg])

    record.errors.clear
    record.test_attr = 'email.mail.com'
    expect { record.valid? }
      .to change(record.errors, :messages).from({})
      .to a_hash_including(test_attr: [error_msg])
  end

  it 'does not add error message if email is valid' do
    record.test_attr = 'email@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email.with-dot@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email_with_underscore@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)

    record.test_attr = 'email-with-dash@mail.com'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)
  end
end
