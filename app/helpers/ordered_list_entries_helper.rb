module OrderedListEntriesHelper


  def entry_name_css_classes(ordered_list_entry)
    list_classes = []
    list_classes << (ordered_list_entry.children? ? 'is-list' : '')
    list_classes << (ordered_list_entry.ancestors? ?  '' : 'top-level-list')

    list_classes
  end

end
