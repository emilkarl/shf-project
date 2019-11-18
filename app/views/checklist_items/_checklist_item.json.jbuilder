json.extract! checklist_item, :id, :title, :description, :is_complete, :date_completed, :created_at, :updated_at
json.url checklist_item_url(checklist_item, format: :json)
