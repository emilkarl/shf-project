json.extract! user_checklist, :id, :user_id, :checklist_id, :date_completed, :created_at, :updated_at
json.url user_checklist_url(user_checklist, format: :json)
