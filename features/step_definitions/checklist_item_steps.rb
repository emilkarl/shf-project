# Steps for working with Checklist Items
#

And(/^the following checklist items exist:$/) do |table|
  table.hashes.each do |item|
    name = item.delete('name') || ''
    description = item.delete('description') || ''
    order_in_list = (item.delete('order in list') || '0').to_i

    checklist_name = item.delete('checklist') || ''

    checklist = Checklist.find_or_create_by!(name: checklist_name)
    FactoryBot.create(:checklist_item, checklist: checklist, name: name, description: description, order_in_list: order_in_list)
  end
end


And("I should see {digits} checklist items listed") do |num|
  step %{I should see #{num} rows in the table with id "checklist-items"}
end


And("I should see the item named {capture_string} in the checklist items table") do | item_name |
  step %{I should see CSS class "name" with text "#{item_name}" in the table with id "checklist-items"}
end


And("I should see {capture_string} as the checklist in the row for {capture_string}") do | checklist_name, checklist_item_name |
  # verify that this checklist_item is in the table
  step %{I should see the item named "#{checklist_item_name}" in the checklist items table}

  table = page.find("table#checklist-items")
  item_name_td = table.find(:xpath, "tbody/tr/td[@class='name' and .//text()='#{checklist_item_name}']")
  item_name_tr = item_name_td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(item_name_tr).to have_xpath("./td[@class='checklist' and .//text()='#{checklist_name}']")
end

