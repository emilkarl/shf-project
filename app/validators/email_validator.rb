class EmailValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)

    unless value.to_s =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      object.errors[attribute] << I18n.t('errors.messages.invalid')
    end
  end
end
