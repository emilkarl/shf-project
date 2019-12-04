class ChecklistItem < ApplicationRecord

  belongs_to :checklist

  validates_presence_of :name
  validates_presence_of :order_in_list

end
