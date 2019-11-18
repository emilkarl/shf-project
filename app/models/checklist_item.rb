class ChecklistItem < ApplicationRecord

  # TODO add  checklist reference (always belongs to a list)

  validates_presence_of :title

end
