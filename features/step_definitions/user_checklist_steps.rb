# Steps for UserChecklist items
#



# ========================
# USER CHECKLIST ITEMS - this should go into a different file (e.g. 'user-checklist-steps.rb')

And("I should see {digits} user checklist items listed") do |num|
  step %{I should see #{num} rows in the table with id "user-checklist-items"}
end


And("I should see the item named {capture_string} in the user checklist items table") do |item_name|
  step %{I should see CSS class "name" with text "#{item_name}" in the table with id "user-checklist-items"}
end


And("I should see {capture_string} as the user checklist in the row for {capture_string}") do |user_checklist_name, user_checklist_item_name|
  # verify that this user_checklist_item is in the table
  step %{I should see the item named "#{user_checklist_item_name}" in the user checklist items table}

  table = page.find("table#user-checklist-items")
  item_name_td = table.find(:xpath, "tbody/tr/td[@class='name' and .//text()='#{user_checklist_item_name}']")
  item_name_tr = item_name_td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(item_name_tr).to have_xpath("./td[@class='user-checklist' and .//text()='#{user_checklist_name}']")
end

