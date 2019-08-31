module PaymentsHelper

  # Create a <span> that has the expire date for the entity with the CSS class
  # set based on whether or not the date has expired and a tooltip that explains it.
  #
  # @param entity [User | Object]- the entity that provides the expiration date. If a User,
  # must respond to :membership_expire_date; else must respond to :branding_expire_date
  #
  # @return [String] - the HTML <span> string
  def expire_date_label_and_value(entity)
    if entity.is_a? User
      expire_date = entity.membership_expire_date
      expire_after_tooltip_title = "#{t('users.show.membership_expire_date_tooltip')}"
    else
      expire_date = entity.branding_expire_date # Company
      expire_after_tooltip_title = "#{t('companies.show.branding_fee_expire_date_tooltip')}"
    end

    unless expire_date
      return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                           "#{t('none_t')}", label_class: 'standard-label')
    end

    tag.p do
      concat tag.span "#{t('activerecord.attributes.payment.expire_date')}: ",
                      class: 'standard-label'
      concat tag.span "#{expire_date}", class: expire_date_css_class(expire_date)
      concat ' '
      concat fas_tooltip(expire_after_tooltip_title)
    end
  end

  def expire_date_css_class(expire_date)
    today = Time.zone.today

    if today < expire_date.months_ago(1)  # expire_date minus one month
      value_class = 'Yes'  # green
    elsif today >= expire_date
      value_class = 'No'
    else
      value_class = 'Maybe'
    end
    value_class
  end


  def payment_button_classes(additional_classes = [])
    %w(btn btn-secondary btn-sm) + additional_classes
  end

  def payment_button_tooltip_text(payment_due_now = false, t_scope = 'users')
    pay_button_tooltip = t("#{t_scope}.show.pay_membership_tooltip")
    pay_button_tooltip += ".  \nNo payment is due now." unless payment_due_now
    pay_button_tooltip
  end


  # TODO abstract out to Payor
  def payment_notes_label_and_value(entity)

    notes = entity.payment_notes(entity.class::THIS_PAYMENT_TYPE)
    display_text = notes.blank? ? t('none_plur') : notes

    field_or_none("#{t('activerecord.attributes.payment.notes')}",
                  display_text, label_class: 'standard-label')

  end
end
