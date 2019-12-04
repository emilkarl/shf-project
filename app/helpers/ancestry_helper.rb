module AncestryHelper


  # Recursively render a partial from an Ancestry arranged subtree.
  # From https://github.com/stefankroes/ancestry/wiki/Nested-HTML-from-the-arrange-method
  def arranged_tree_table_rows(tree, partial_name = 'tree_node')
    tree.each do |node, children|
      concat render partial: partial_name, object: node
      arranged_tree_table_rows(children) if children.present?
    end
  end


# From https://github.com/stefankroes/ancestry/wiki/Nested-HTML-from-the-arrange-method
#
# If you have a need to render your ancestry tree of any depth you can use
# the following helper to make it so.
# The Helper takes some options, mostly for styling.
# There is an option for sorting the tree by the current level (or group) we are in.
#
# Note: This helper should not care about filtering or children depth.
# That should be handled via the normal ancestry methods before arrange() is called.
#
# Secondary Note: This helper also assumes you are using the has_ancestry :cache_depth => true option.
# If you are not using this, remove the references in the helper to ancestry_depth.
#
#
# Configuration options
#:list_type # the type of list to render (ul or ol)
#:list_style # this is used for setting up some pre-formatted styles. Can be removed if not needed.
#:ul_class # applies given class(es) to all parent list groups (ul or ol)
#:ul_class_top # applies given class(es) to parent list groups (ul or ol) of depth = 0
#:ul_class_children # applies given class(es) to parent list group (ul or ol) of depth > 0
#:li_class # applies given class(es) to all list items (li)
#:li_class_top # applies given class(es) to list items (li) of depth = 0
#:li_class_children # applies given class(es) to list items (li) of depth > 0
#
# arranged as tree expects 3 arguments. The hash from has_ancestry.arrange() method,
# options, and a render block
#
  def arranged_tree_as_list(hash, options = {}, &block)

    options = {
        list_type: :ul,
        list_style: '',
        ul_class: [],
        ul_class_top: [],
        ul_class_children: [],
        li_class: [],
        li_class_top: [],
        li_class_children: [],
        sort_by: []
    }.merge(options)

    # setup any custom list styles you want to use here. An example is excluded
    # to render bootstrap style list groups. This is used to keep from recoding the same
    # options on different lists
    case options[:list_style]
      when :bootstrap_list_group
        options[:ul_class] << ['list-group']
        options[:li_class] << ['list-group-item']
    end
    options[:list_style] = ''

    output = ''

    # sort the hash key based on sort_by options array
    unless options[:sort_by].empty?
      hash = Hash[hash.sort_by { |k, _v| options[:sort_by].collect { |sort| k.send(sort) } }]
    end

    current_depth = 0
    hash.each do |object, children|

      li_classes = options[:li_class]
      li_classes_to_add = (current_depth == 0 ? :li_class_top : :li_class_children)
      li_classes += options[li_classes_to_add]

      if children.size > 0
        output << content_tag(:li, capture(object, &block) + arranged_tree_as_list(children, options, &block).html_safe, class: li_classes)
      else
        output << content_tag(:li, capture(object, &block), class: li_classes).html_safe
        current_depth = object.depth
      end
    end

    unless output.blank?
      ul_classes = options[:ul_class]
      ul_classes_to_add = (current_depth == 0 ? :ul_class_top : :ul_class_children)
      ul_classes += options[ul_classes_to_add]

      output = content_tag(options[:list_type], output.html_safe, class: ul_classes)
    end

    output.html_safe
  end

end
