module ChecklistCommonHelper


  # These might be used for UserChecklist views.  Keeping this file in the repo for now.

  # Return a string for displaying the date completed
  #
  # @param [Checklist | Checklist_item] item - must be able to respond to complete? and date_completed
  # @return [String] - an empty string if the item is not complete, else the string representation of the date_completed
  def date_completed_display(item)
    item.complete ? item.date_completed.to_s : ''
  end


  # Return HTML string that displays the completed? value and,
  # if the item is completed, the date completed
  # in bootstrap columns
  #
  def is_completed_as_cols(item, complete_col_class: 'col-sm-3', date_complete_col_class: 'col')

    is_complete_div = tag.div(class: complete_col_class) do
      tag.p(tag.b(I18n.t('checklist_common.complete')) + '? ' + item.complete?)
    end

    date_complete_div = if item.complete?
                          tag.div(class: date_complete_col_class) do
                            tag.b(I18n.t('checklist_common.date_completed')) + ' ' + item.date_completed
                          end
                        else
                          ''
                        end

    is_complete_div + date_complete_div
  end

end
