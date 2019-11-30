module AdminMailerHelper

  # @return [String] - html with .label CSS spanning (surrounding) the label_text
  #    and .value CSS spanning the value_text (so these can be styled in emails).
  #    The separator is put inbetween them
  def label_and_value(label_text, value_text, separator: ': ')
    html_str = ''
    html_str << content_tag(:span, label_text, class: 'label') << separator << content_tag(:span, value_text, class: 'value')
    html_str.html_safe
  end

end
