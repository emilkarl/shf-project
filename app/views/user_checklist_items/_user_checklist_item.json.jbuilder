json.extract! user_checklist_item, :id, :checklist_item_id, :user_id, :time_completed, :created_at, :updated_at
json.url user_checklist_item_url(user_checklist_item, format: :json)
