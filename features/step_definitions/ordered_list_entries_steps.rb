# Steps for OrderedListEntry items
#
And(/^the following ordered list entries exist:$/) do |table|

  table.hashes.each do |item|

    name = item.delete('name') || ''
    description = item.delete('description') || ''
    list_position = (item.delete('list position') || '0').to_i

    parent_name = item.delete('parent name') || ''

    list_entry = OrderedListEntry.find_by(name: name)

    list_entry = FactoryBot.create(:ordered_list_entry, name: name, description: description,
                                   parent_name: parent_name,
                                   list_position: list_position) if list_entry.blank?
    list_entry
  end

end


CHECKLIST_TABLE_ID = 'checklists'
NAME_CSSCLASS = 'name'
LIST_POSITION_CSSCLASS = 'list-position'
PARENT_LIST_ID = 'ordered_list_entry_parent_id'


def get_checklist_table
  page.find_by_id(CHECKLIST_TABLE_ID)
end


# the table is identified by an id or caption; @see the have_table method in capybara-3.16.1/lib/capybara/node/matchers.rb
And("I should see {digits} rows in the table {capture_string}") do |num_rows, table_locator|
  expect(page).to have_table(table_locator)
  # :table, locator
  table = get_checklist_table
  expect(table).to have_selector('tr', count: num_rows)
end


And("I should see {digits} checklist entries listed") do |num|
  step %{I should see #{num} rows in the table "#{CHECKLIST_TABLE_ID}"}
end


# TODO generalize this step
And("I should{negate} see {capture_string} in the checklists table") do |negate, entry_text|
  expect(page).send (negate ? :not_to : :to), have_table(CHECKLIST_TABLE_ID, text: entry_text)
end


# TODO generalize this step
And("I should{negate} see entry named {capture_string} in the checklists table and it shows position {digits}") do |negate, entry_name, position|
  step %{I should#{negate} see "#{entry_name}" in the checklists table}

  table = get_checklist_table
  item_name_td = table.find(:xpath, "tbody/tr/td[ (#{with_class_test(NAME_CSSCLASS)}) and (descendant::text()[contains(.,'#{entry_name}')]) ]")
  item_name_row = item_name_td.find(:xpath, 'parent::tr') # get the parent tr of the td

  expect(item_name_row).to have_xpath(".//td[(#{with_class_test(LIST_POSITION_CSSCLASS)}) and .//text()='#{position}']")
end


def with_class_test(class_name)
  # must include spaces around the class name, otherwise it will find elements with class names that include that as a substring
  "contains(@class,' #{class_name} ') or @class='#{class_name}'"
end


And("I select {capture_string} as the parent list") do |parent_list_name|
  step %{I select "#{parent_list_name}" in select list "#{PARENT_LIST_ID}"}
end

And(/^I am (on )*the page for ordered list entry named "([^"]*)"$/) do |_grammar_fix_on, list_name|
  olist_entry = OrderedListEntry.find_by_name(list_name)
  visit path_with_locale(ordered_list_entry_path olist_entry)
end
