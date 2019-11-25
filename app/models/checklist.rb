class Checklist < ApplicationRecord

  has_ancestry
  has_many :checklist_items

  validates_presence_of :title


  def complete?
    return false if checklist_items.empty?
    checklist_items.reduce(true) { |all_completed, item| all_completed && item.complete }
  end


  def date_completed
    checklist_items.map(&:date_completed).max
  end


  # Inserts the given item into checklist_items before the element with the given +index+.
  # If no index is given, append the item at the end. (index = -1)
  # index is used in the same way as Array#insert
  # See Array#insert for details
  #
  # After the insert, update the order_in_list [= position] for all checklist_items.
  #
  # @param index [Integer] - the 0-based position that the item will be put _before_
  # @param checklist_item [ChecklistItem] - the item inserted
  #
  def insert(checklist_item, index = -1)
    checklist_items.insert(index, checklist_item)
    update_item_order_numbers
  end


  # Append checklist_item to the end of checklist_items
  def <<(checklist_item)
    insert(checklist_item)
  end


  # Delete the item with the given id from checklist_items.
  # After the deletion, update the order_in_list [= position] for all checklist_items.
  def delete_by_id(checklist_item_id)
    delete(ChecklistItem.find(checklist_item_id)) if ChecklistItem.exists?(checklist_item_id)
  end


  # Delete the first item found with the given title from checklist_items.
  # After the deletion, update the order_in_list [= position] for all checklist_items.
  def delete_by_title(checklist_item_title)
    delete(ChecklistItem.find_by(title: checklist_item_title)) if ChecklistItem.exists?(title: checklist_item_title)
  end


  # Delete the ChecklistItem from checklist_items.
  # After the deletion, update the order_in_list [= position] for all checklist_items.
  def delete(checklist_item)
    if checklist_items.include?(checklist_item)
      checklist_items.delete(checklist_item)
      update_item_order_numbers
    end
  end


  def completed_items
    checklist_items.select(&:complete)
  end


  def not_completed_items
    checklist_items.reject(&:complete)
  end


  def update_item_order_numbers
    checklist_items.each_with_index { |item, i| item.order_in_list = i }
  end
end
