$(function() {
  'use strict';

  // Successful delete of file attached to application
  $('body').on('ajax:complete', 'a[class="action-delete"]', function (e, response) {

    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      $('#uploaded-files').html(data.uploaded_html);
      $('[data-toggle="tooltip"]').tooltip();
    }
  });

  $('body').on('ajax:complete', '.edit-subcategories-button', function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving an edit row from server - replace display row with that
      var $displayRow = $('#subcategories-display-row-' + data.business_category_id);

      $displayRow.replaceWith(data.edit_row);

      initSelect2Fields('.subcategories_field');

      return false;
    }
  });

  $('body').on('ajax:complete', '.edit-subcategories-cancel-button', function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving display row from server - replace edit row with that
      var $editRow = $('#subcategories-edit-row-' + data.business_category_id);

      $editRow.replaceWith(data.display_row);
      return false;
    }
  });

  $('body').on('ajax:complete', '.edit-category-form', function(e, response) {
    if (Utility.httpErrorOccurred(response) === false) {
      var data = JSON.parse(response.responseText);

      var $editRow = $('#subcategories-edit-row-' + data.business_category_id);

      $editRow.replaceWith(data.display_row);

      return false;
    }
  });

  // Check to see if any file delivery radio button is selected -
  // if so, remove "disable" from submit button, hide explain text
  // if not, set callback function, on button change, to perform above actions

  var button_checked = false;
  var radio_buttons = $('input:radio[name="shf_application[file_delivery_method_id]"]');

  radio_buttons.each(function () {
    if ($(this).is(':checked')) {
      enable_submit_button();
      button_checked = true;
      return false;
    }
  });

  if ( !button_checked ) {
    radio_buttons.each(function () {
      $(this).change(function() {
        enable_submit_button();
        remove_change_callback_for_radio_buttons(radio_buttons);
      });
    });
  }
});

function enable_submit_button () {
  $('.app-submit').prop('disabled', false);
  $('.submit-button-explain').hide();
}

function remove_change_callback_for_radio_buttons (radio_buttons) {
  radio_buttons.each(function () {
    // $(this).off('change');
  });
}
