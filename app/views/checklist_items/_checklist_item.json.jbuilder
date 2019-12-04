json.extract! checklist_item, :id, :name, :description, :order_in_list, :checklist_id, :created_at, :updated_at
json.url checklist_item_url(checklist_item, format: :json)
