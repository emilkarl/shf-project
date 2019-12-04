json.extract! user_checklist, :id, :checklist_id, :user_id, :created_at, :updated_at
json.url user_checklist_url(user_checklist, format: :json)
