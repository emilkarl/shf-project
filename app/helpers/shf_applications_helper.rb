module ShfApplicationsHelper

  def can_change_state?
    policy(@shf_application).permitted_attributes_for_edit.include? :state
  end

  # @return [String] approved status with the date approved
  def app_state_and_date(shf_app)
    return '' unless shf_app

    displayed_date = if shf_app.accepted?
                       shf_app.when_approved.present? ? shf_app.when_approved : shf_app.updated_at
                     else
                       shf_app.updated_at
                     end
    "#{shf_app_state_translated(shf_app)} - #{displayed_date.strftime('%F')}"
  end

  def shf_app_state_translated(shf_app)
    # Cannot use '.human_state' because it calls '.display_name',
    # which is cached/memoized.
    # If the locale is changed, then the .display_name is no longer accurate because it
    #  is now the translation for the previous locale.
    # Hence we have to call this every time.
    #  (Another way might be to set up an observer on changing the locale.)
    shf_app_aasm = shf_app.aasm
    shf_app_aasm.state_object_for_name(shf_app_aasm.current_state).localized_name
  end

  def business_categories_str(application)
    cats_str = ''
    return cats_str if application.blank?

    application.business_categories&.roots.order(:name).each do |category|
      cats_str += ', ' unless cats_str.empty?
      cats_str += category.name
      sub_cats = application.business_subcategories(category)

      cats_str += subcategories_list_in_parens(sub_cats)
    end
    cats_str
  end

  def subcategories_list_in_parens(subcategories)
    return '' unless subcategories.present?

    " (#{t('including')}: #{subcategories.map(&:name).join(', ')})"
  end

  # The AASM gem caches the display_name for a State.  We cannot do that because
  # the I18n.locale may have changed, so we must get the localized name every time
  def states_selection_list
    ShfApplication.aasm.states.map { |state| [state.localized_name, state.name.to_s] }
  end

  def reasons_collection(other_reason_value, other_reason_text)
    collection = AdminOnly::MemberAppWaitingReason.all.to_a
    collection << AdminOnly::MemberAppWaitingReason.new(id: other_reason_value, "name_#{I18n.locale}" => "#{other_reason_text}")
    collection
  end

  def selected_reason_value(member_app, other_reason_value)
    (!member_app.custom_reason_text.blank?) ? other_reason_value : member_app.member_app_waiting_reasons_id
  end

  # the method to use to get the name for a reason, given the locale
  # If no locale is given, the current locale is used.
  # If the locale given isn't found or defined, the default name method is used
  def reason_name_method(locale = I18n.locale)
    reason_method 'name', locale
  end

  # the method to use to get the description for a reason, given the locale
  # If no locale is given, the current locale is used.
  # If the locale given isn't found or defined, the default name method is used
  def reason_desc_method(locale = I18n.locale)
    reason_method 'description', locale
  end

  # a collection of arrays with [the name of the reasons for waiting, the reason (object)]
  # in the locale
  def reasons_for_waiting_names(use_locale = I18n.locale)
    reasons_for_waiting_info('name', use_locale)
  end

  # a collection of arrays with [the descriptions of the reasons for waiting,  the reason (object)]
  # in the locale
  def reasons_for_waiting_descs(use_locale = I18n.locale)
    reasons_for_waiting_info('description', use_locale)
  end

  def list_app_categories application, separator = ', '
    if application&.business_categories.any?
      application.business_categories.roots.includes(:shf_applications)
                 .map(&:name).sort.join(separator)
    end
  end

  # @return [String] - standarize the classes used for the Admin (review) status buttons
  def admin_status_btn_css(other_css_str = '')
    "btn btn-sm btn-outline-primary #{other_css_str}"
  end

  # Return the instructions for answering additional questions for the given business categories
  # @return [String] Instructions for answering additional questions for each business category, with HTML tags
  # @param [Array<BusinessCategory>] business_categories - list of business categories to show
  # @param [String] i18n_scope - scope for looking up the message(s) to display
  def instructions_for_additional_category_qs(business_categories, i18n_scope)
    instructions = I18n.t("#{i18n_scope}.success_more_questions_instructions")
    "<div class='addtl-category-qs'><p class='addtl-category-qs-instructions'>#{instructions}</p>#{links_for_more_category_questions(business_categories)}</div>"
  end

  # @return [String] HTML string with a <ul> for the categories, <li> for each category and the category linklink
  def links_for_more_category_questions(categories = [], ul_class: 'category-links', li_class: 'category-link')
    ul_items = categories.map { |cat| link_for_more_category_questions(cat, li_class: li_class) }
    "<ul class='#{ul_class}'>#{ul_items.join}</ul>"
  end

  def link_for_more_category_questions(category, li_class: 'category-link')
    a_href_open = "<a href=#{category.apply_qs_url} target='_blank'>"
    href_name = "<span class=name>#{category.name}</span>"
    href_link = "#{category.apply_qs_url} #{external_link_icon}"
    "<li class='#{li_class}'>#{a_href_open}#{href_name} #{href_link}</a></li>"
  end

  # --------------------------------------------------------------------------------------------

  private

  def reason_method(method_prefix, locale)
    possible_method = "#{method_prefix}_#{locale}".to_sym
    (AdminOnly::MemberAppWaitingReason.new.respond_to?(possible_method) ? possible_method : AdminOnly::MemberAppWaitingReason.send("default_#{method_prefix}_method".to_sym))
  end

  def reasons_for_waiting_info(method_prefix, locale)
    method_name = reason_method(method_prefix, locale)
    AdminOnly::MemberAppWaitingReason.all.map { |r| [r.id, r.send(method_name)] }
  end

  def file_delivery_radio_buttons_collection(locale = I18n.locale)
    collection = []
    # Default option will be the first (left-most) button in the set
    AdminOnly::FileDeliveryMethod.order('default_option DESC').each do |delivery_method|
      option_text = delivery_method.description_for_locale(locale)
      option_text += '*' if delivery_method.email?
      option_text += '**' if delivery_method.mail?
      collection << [delivery_method.id, option_text]
    end
    collection
  end

  def file_delivery_method_status(application, locale = I18n.locale)

    fdm = application.file_delivery_method
    fdm_desc = fdm ? fdm.description_for_locale(locale) : t('none_plur')
    status = t('shf_applications.show.files_delivery_method') + ': ' + fdm_desc

    if fdm
      status += ' ' +
        t('shf_applications.show.method_chosen_when',
          date: application.file_delivery_selection_date)
    end

    status
  end

end
