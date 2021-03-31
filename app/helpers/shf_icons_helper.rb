# Standardized icon styles, helper methods, and names to use in this application.
#
# This defines (creates) helper methods for using FontAwesome icons in the application.
#  - it defines a standard method for using an icon (ex: 'edit_icon'),
#  - it defines the standard look (FontAwesome style, color and other html_options), and
#  - it defines a standard method for getting the [String] name of the icon (ex: 'edit_icon_fa_name')
#
# This defines exactly which FontAwesome icons are used and how they look
#
# ** You should ALWAYS USE THE HELPER METHODs instead of using the constants here
#    or specifying the FontAwesome icon yourself. **
#
# That way, this is the only place the the FontAwesome icons need to be specified.
# (It is DRY.)
# And if we change them, this is the only place that needs to be changed.
#
# These methods provide a single point of connection (binding) to the FontAwesome icon method.
#
# Here are some general examples. (More details are in the documentation and methods below.)
#
# @example: Assume that information below is set so that "edit_icon" is the
#   helper method to use whenever you want to show an icon to the user to edit something.
#   You could use the method like this in a view
#     link_to(edit_icon, edit_user_profile_path(@user))
#   This would show the icon as a link to the edit_user_profile(@user) path
#
#
# @example: Assuming there a is 'destroy' icon defined and helper methods
#   are defined to show when something needs to be _destroyed:_
#   - assume "destroy_icon" is a method defined below that shows the right icon,
#       and that it uses FA_DESTROY to define exactly this FontAwesome icon to use
#   - assume that the constant FA_DESTROY is set to the "trash" FontAwesome icon.
#
#   You would use the "destroy_icon" method to display the correct icon, ex:
#      link_to(destroy_icon, destroy_user_profile_path(@user))
#   and it would display the "trash" FontAwesome icon in the line
#
#   Later, if we decide to use a different FontAwesome icon
#     (e.g. the "dumpster_fire") FontAwesome icon,
#   the "destroy_icon" method stays the same. None of the views that use that method
#   need to be changed. We only need to change the FA_DESTROY constant here
#   so that it refers to "dumpster_fire" instead of "trash".
#    link_to(destroy_icon, destroy_user_profile_path(@user))  does not need to be changed.
#   After the change, it will automatically now display the "dumpster_fire" FontAwesome icon.
#
# @example:
#   To display the destroy icon with a tooltip (text that shows when you hover
#   on the icon), you'd put this in your view:
#
#     destroy_icon(html_options: { 'data-toggle': 'tooltip',
#                                  title: "Delete me!" })
#
#   This will:
#     - display the icon defined in the METHODS_AND_ICONS array (e.g. FA_TRASH),
#     - call the method 'destroy_icon' (see how it is defined in the  module_eval below)
#     - per the HTML that is given with html_options:
#         when the user hovers on the icon, display a tooltip with "Delete me!"
#         (The title: string would really be a call to I18n.t to show it in the correct language. )
#
#
# NOTE about tooltips:
#   There is a specific helper method 'fas_tooltip(...) that can also be used.
#   It is defined in application_helper.rb.
#
#
# @example:
#   to display the view icon with a specific color:
#     view_icon(html_options: {style: "color: #123123;"})
#
#
# @example:
#   to add a class to the view icon:
#     view_icon(html_options: {class: 'flurb'})
#
#
# See the documentation below for more details.
#
module ShfIconsHelper

  FA_STYLE_DEFAULT = 'fas'

  # ---------------------------------------
  # Define the FontAwesome icons to be used
  #

  # Standard actions: edit, view, destroy, etc.,  icons:
  FA_EDIT = 'edit'
  FA_VIEW = 'eye'
  FA_DESTROY = 'trash-alt'


  # Icons for specific pages/views:
  FA_USER_PROFILE = 'id-card'
  FA_USER_ACCOUNT = 'folder'


  # Commonly used actions and information:
  FA_EXTERNAL_LINK = 'external-link-alt'
  FA_NOT_COMPLETE_CHECK_CIRCLE = 'circle'
  FA_COMPLETE_CHECK = 'check-circle'
  FA_NOT_COMPLETE_CHECK_SQ = 'square'
  FA_COMPLETE_CHECK_SQ = 'check-square'
  FA_WARNING = 'exclamation-triangle'
  FA_PROBLEM = 'times-circle'
  FA_PLUS = 'plus'
  FA_QUESTION = 'question-circle'

  FA_TOOLTIP = 'info-circle' # Note that there is a specific helper method 'fas_tooltip(...) that can be used (Defined in application_helper.rb)

  FA_BLANK = 'blank' # placeholder


  # arrows
  FA_ARROW_LEFT = 'arrow-left'
  FA_ARROW_RIGHT = 'arrow-right'
  FA_ARROW_UP = 'arrow-up'
  FA_ARROW_DOWN = 'arrow-down'
  FA_ARROW_CIRCLE_LEFT = 'arrow-circle-left'
  FA_ARROW_CIRCLE_RIGHT = 'arrow-circle-right'
  FA_ARROW_CIRCLE_UP = 'arrow-circle-up'
  FA_ARROW_CIRCLE_DOWN = 'arrow-circle-down'
  FA_ARROW_ALT_CIRCLE_LEFT = 'arrow-alt-circle-left'
  FA_ARROW_ALT_CIRCLE_RIGHT = 'arrow-alt-circle-right'
  FA_ARROW_ALT_CIRCLE_UP = 'arrow-alt-circle-up'
  FA_ARROW_ALT_CIRCLE_DOWN = 'arrow-alt-circle-down'
  FA_LONG_ARROW_ALT_LEFT = 'long-arrow-alt-left'
  FA_LONG_ARROW_ALT_RIGHT = 'long-arrow-alt-right'
  FA_LONG_ARROW_ALT_UP = 'long-arrow-alt-up'
  FA_LONG_ARROW_ALT_DOWN = 'long-arrow-alt-down'


  # -----------------------------------------------------------------------------------
  # METHODS_AND_ICONS is the list that defines helper method names
  # and connects each method name to an icon constant above.
  #
  # Create an entry for each method that you want to define
  #  and the icon name it should use.
  # It should have a "method_name:" key
  #  with the value set to a string that will be the start of the method names,
  #  and an "icon: " key with the value set to a FontAwesome constant defined
  #  above (which specifies the main part of the FontAwesome icon name to be used).
  #
  #  @example  { method_name_start: 'next_arrow', icon: FA_ARROW_RIGHT }
  #
  #  Two methods will be defined for each entry.  (see the module_eval below):
  #    1) a helper method that will produce the HTML needed for the icon
  #    2) a helper method that returns the name of the FontAwesome icon used
  #
  #  @example:
  #   To create the methods for the standard edit icon:
  #   1. assume that FA_EDIT = 'edit'  is defined above
  #   2. and that this entry is in the METHODS_AND_ICONS list:
  #        { method_name_start: 'edit', icon: FA_EDIT },
  #
  #  Two methods will be defined in the module_eval code below:
  #   1) edit_icon(...) = a method that can be used to generate the HTML for the FA_EDIT icon
  #       Parameters for this method are the same as for the FontAwesome icon() method
  #       except they are all keyword arguments.  All are optional.
  #       (See the comments below where the method is defined in the module_eval )
  #
  #   2) edit_fa_icon_name = a method that returns the FontAwesome icon name for 'edit'
  #
  #  This uses the _method_name_start:_ value  as the start of the name for the methods created.
  #   For this entry,  method_name_start: 'edit'  so the methods defined will start with "edit"
  #   The full method names will be "edit_icon" and "edit_fa_icon_name"
  #
  #   In the entry, icon: FA_EDIT  means that the FontAwesome icon defined by
  #   FA_EDIT will be used. Since FA_EDIT = 'edit', the the FontAwesome
  #   icon used will be "fa-" + "edit" = "fa-edit"
  #
  #   These are the 2 methods defined that can be used in views and controllers
  #   as helper methods:
  #
  #      def edit_icon(html_options: {}, fa_style: FA_STYLE_DEFAULT, text: nil)
  #         get_fa_icon(fa_style, FA_EDIT, text, html_options)
  #       end
  #
  #      def edit_fa_icon_name
  #        "fa-edit"
  #      end
  #
  # You can then use those helper methods in views:
  #   = link_to edit_icon, admin_only_user_profile_edit_path(user), title: t('.edit_user_profile', name: user.full_name)
  #
  # instead of the old way where you had to specify the FontAwesome icon to use:
  #   = link_to icon('fas', 'edit'), admin_only_user_profile_edit_path(user), title: t('.edit_user_profile', name: user.full_name)
  #
  #
  # @example
  #  In a view, instead of writing this:
  #
  #  # OLD WAY (BAD)
  #  - trash_icon = icon('fas', 'trash')
  #  = link_to trash_icon, remove_attachment_shf_application_path(shf_application.id,
  #                             shf_application: { uploaded_files_attributes: { id: uploaded_file.id,  '_destroy' => true }}),
  #                           method: :put, remote: true,
  #                           id: "uploaded-file-#{uploaded_file.id}",
  #                           class: "action-delete",
  #                           data: { confirm: "#{t('shf_applications.uploads.confirm_delete', filename: uploaded_file.actual_file_file_name)}" }
  #
  #
  # use the helper method like this:
  #
  # # NEW WAY WITH THE HELPER METHODS (GOOD)
  # = link_to destroy_icon, remove_attachment_shf_application_path(shf_application.id,
  #                             shf_application: { uploaded_files_attributes: { id: uploaded_file.id,  '_destroy' => true }}),
  #                           method: :put, remote: true,
  #                           id: "uploaded-file-#{uploaded_file.id}",
  #                           class: "action-delete",
  #                           data: { confirm: "#{t('shf_applications.uploads.confirm_delete', filename: uploaded_file.actual_file_file_name)}" }
  #
  #
  #  @example:
  #   assuming FA_COMPLETE_CHECK = 'check-circle'
  #   for this entry:  { method_name_start: 'complete_check', icon: FA_COMPLETE_CHECK },
  #
  #   these methods are defined:
  #
  #      def complete_check_icon(html_options: {}, fa_style: FA_STYLE_DEFAULT, text: nil)
  #         get_fa_icon(fa_style, FA_COMPLETE_CHECK, text, html_options)
  #       end
  #
  #      def complete_check_fa_icon_name
  #        "fa-check-circle"
  #      end
  #
  #
  #-----------------------------------------------------------------------


  # Try to keep these in the same order as the icon constant groups above.
  #
  METHODS_AND_ICONS = [
      { method_name_start: 'edit', icon: FA_EDIT },

      { method_name_start: 'view', icon: FA_VIEW,
        color: 'blue',
        fa_style: 'far'
      },

      { method_name_start: 'destroy', icon: FA_DESTROY,
        color: 'red',
        fa_style: 'far'
      },


      { method_name_start: 'user_profile', icon: FA_USER_PROFILE },
      { method_name_start: 'user_account', icon: FA_USER_ACCOUNT },


      { method_name_start: 'external_link', icon: FA_EXTERNAL_LINK },
      { method_name_start: 'not_complete_check', icon: FA_NOT_COMPLETE_CHECK_CIRCLE, fa_style: 'far' },
      { method_name_start: 'complete_check', icon: FA_COMPLETE_CHECK },
      { method_name_start: 'not_complete_check_sq', icon: FA_NOT_COMPLETE_CHECK_SQ, fa_style: 'far' },
      { method_name_start: 'complete_check_sq', icon: FA_COMPLETE_CHECK_SQ, fa_style: 'far' },
      { method_name_start: 'warning', icon: FA_WARNING },
      { method_name_start: 'problem', icon: FA_PROBLEM },
      { method_name_start: 'plus', icon: FA_PLUS },
      { method_name_start: 'question', icon: FA_QUESTION, fa_style: 'far' },


      { method_name_start: 'next_arrow', icon: FA_ARROW_RIGHT },
      { method_name_start: 'previous_arrow', icon: FA_ARROW_LEFT },

      { method_name_start: 'tooltip', icon: FA_TOOLTIP },

      { method_name_start: 'blank', icon: FA_BLANK },


      # arrows (These use the FontAwesome name to start the method names instead of a general action or common use)
      { method_name_start: 'arrow_left', icon: FA_ARROW_LEFT },
      { method_name_start: 'arrow_right', icon: FA_ARROW_RIGHT },
      { method_name_start: 'arrow_up', icon: FA_ARROW_UP },
      { method_name_start: 'arrow_down', icon: FA_ARROW_DOWN },
      { method_name_start: 'arrow_circle_left', icon: FA_ARROW_CIRCLE_LEFT },
      { method_name_start: 'arrow_circle_right', icon: FA_ARROW_CIRCLE_RIGHT },
      { method_name_start: 'arrow_circle_up', icon: FA_ARROW_CIRCLE_UP },
      { method_name_start: 'arrow_circle_down', icon: FA_ARROW_CIRCLE_DOWN },
      { method_name_start: 'arrow_alt_circle_left', icon: FA_ARROW_ALT_CIRCLE_LEFT },
      { method_name_start: 'arrow_alt_circle_right', icon: FA_ARROW_ALT_CIRCLE_RIGHT },
      { method_name_start: 'arrow_alt_circle_up', icon: FA_ARROW_ALT_CIRCLE_UP },
      { method_name_start: 'arrow_alt_circle_down', icon: FA_ARROW_ALT_CIRCLE_DOWN },
      { method_name_start: 'long_arrow_alt_left', icon: FA_LONG_ARROW_ALT_LEFT },
      { method_name_start: 'long_arrow_alt_right', icon: FA_LONG_ARROW_ALT_RIGHT },
      { method_name_start: 'long_arrow_alt_up', icon: FA_LONG_ARROW_ALT_UP },
      { method_name_start: 'long_arrow_alt_down', icon: FA_LONG_ARROW_ALT_DOWN },

  ]


  # this method protects access to internals and also provides a way to test
  def self.methods_and_icons
    METHODS_AND_ICONS
  end


  def methods_and_icons
    self.class.methods_and_icons
  end


  # -------------------------------------------------------------
  # Define the helper methods for each entry in METHODS_AND_ICONS
  #
  METHODS_AND_ICONS.each do |method_info|

    # Define a helper method that returns the HTML for a FontAwesome icon.
    # Can use this helper method in views instead of specifying the FontAwesome icon directly.
    #
    # The name of the method will start with method_info[:method_name_start]
    # and the FontAwesome icon will be method_info[:icon]
    #
    # Parameters are the same as those accepted by the FontAwesome icon() method.
    # All parameters are keywords and are all optional. ()All are passed on to the
    #   FontAwesome icon() method.)
    #   html_options:  [Hash] - HTML options to be applied to the icon.  Default = {}
    #   fa_style: [String] - a specific FontAwesome style to use. Default = FA_STYLE_DEFAULT = 'fas'
    #   text: [String] - any additional text to display.  Default = nil
    #

    icon_fa_style = method_info.fetch(:fa_style, FA_STYLE_DEFAULT)
    icon_html_options = method_info.fetch(:html_options, {})
    icon_color = method_info.fetch(:color, false)

    # if there is a color defined, create the string to use in the style key
    #  Note this will overwrite any 'color: zzz' in the style:  string  defined in html_options
    if icon_color
      # replace any color defined in the html_options
      if icon_html_options.has_key?(:style)
        icon_html_options[:style].gsub!(/color:(.*[^;])/, "color: #{icon_color}")
      else
        icon_html_options[:style] = "color: #{icon_color};"
      end
    end


    module_eval <<-end_icon_method, __FILE__, __LINE__ + 1
      def #{method_info[:method_name_start]}_icon(html_options: #{icon_html_options},
                       fa_style: '#{icon_fa_style}',
                       text: nil)

        default_html_options = #{icon_html_options}
        merged_html_options = default_html_options.merge(html_options)

        get_fa_icon(fa_style, '#{method_info[:icon]}', text, merged_html_options)
      end
    end_icon_method

    # Define a helper method that will return the font awesome icon name [String].
    # Ex:  blank_fa_icon_name
    #   will return 'fa-blank'
    module_eval <<-end_icon_name_method, __FILE__, __LINE__ + 1
      def #{method_info[:method_name_start]}_fa_icon_name
        "fa-#{method_info[:icon]}"
      end
    end_icon_name_method
  end


  private

  # Single point of connection (binding) to the FontAwesome icon method
  def get_fa_icon(fa_style, fa_icon, text = nil, html_options = {})
    icon(fa_style, fa_icon, text, html_options)
  end
end
