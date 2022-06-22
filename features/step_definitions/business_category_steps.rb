And(/^the following business categories exist$/) do |table|
  table.hashes.each do |business_category|

    subcategories = business_category.delete('subcategories')

    cat = FactoryBot.create(:business_category, business_category)
    if subcategories
      subcategories.split(/\s*,\s*/).each do |subcategory_name|
        FactoryBot.create(:business_category, name: subcategory_name, parent_id: cat.id)
      end
    end
  end
end


And(/^I navigate to the business category edit page for "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(edit_business_category_path(business_category))
end

And(/^I select "([^"]*)" Category/) do |element|
  # You must use a driver that supports javascript if using this step.

  # 5/27/2018 - we are using "collection_check_boxes" helper in the application
  # form.  This sets a hidden field that ensures that business_categories (for
  # the membership application) is updated even if no categories are checked in
  # the form (see "Gotcha" in documentation for that method).
  # However, this hidden field has the same name as all of the checkboxes in the
  # collection.  As a result, all tested JS-capable drivers (Chrome, Selenium,
  # Poltergeist) fail to find the checkbox unless we set "visible" to either
  # :false or :any.
  # Also the capybara method for checking a checkbox ("page.check(element)")
  # fails becuase it first executes a "find" for the element and that fails
  # for the same reason (and there no way to override this).
  # Hence the need to execute some JS to check the checkbox.

  # 2019-01-28 AE:  If your test doesn't really care _which_ category you need to pick
  # then just choose the first one.  The id of each category checkbox is
  #  shf_application_business_category_ids_<number>
  # So you can actually check/uncheck specific categories if you know the
  # number (e.g. the n-th one).
  # You can then just use this step to check (select) a category:
  #    And I check the checkbox with id "shf_application_business_category_ids_1"
  # or this one to unselect:
  #    And I uncheck the checkbox with id "shf_application_business_category_ids_1"
  #

  # TODO is it really necessary to run a java script to do this?  Why not use ele.check ?
  #
  ele = find :field, element, visible: :any
  page.evaluate_script("$(#{ele[:id]}).prop('checked', true)") # ex: $(shf_application_business_category_ids_1).prop('checked', true)
end

And(/^I unselect "([^"]*)" Category/) do |element|
  # See comments above

  ele = find :field, element, visible: :any
  page.evaluate_script("$(#{ele[:id]}).prop('checked', false)")
end

Given(/^I am on the business category "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(business_category_path(business_category))
end

And(/I should( not)? see "([^"]*)" in the business categories table$/) do | negate, cmpy |
  step %{I should#{negate} see xpath "tr[td//text()[contains(., '#{cmpy}')]]"}
end
