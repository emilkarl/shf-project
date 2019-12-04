class Checklist < ApplicationRecord

  has_ancestry

  has_many :checklist_items

  validates_presence_of :name


  def self.arrange_as_array(options = {}, hash = nil)
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.nil?
    end
    arr
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
    @item_ids_by_order_nums = item_ids_by_order_nums.reject { |item_id| item_id == checklist_item.id } # take it out of the list if it's in there
    @item_ids_by_order_nums.insert(index, checklist_item.id)
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


  # Delete the ChecklistItem from checklist_items.
  # After the deletion, update the order_in_list [= position] for all checklist_items.
  def delete(checklist_item)
    if checklist_items.include?(checklist_item)
      checklist_items.delete(checklist_item)
      @item_ids_by_order_nums = item_ids_by_order_nums.reject { |item_id| item_id == checklist_item.id } # take it out of the list if it's in there
      update_item_order_numbers
    end
  end


  # @return [Array] - a list of all Checklists that could be assigned as a parent to this one
  def possible_parents(order_by_attrib = 'name')
    parents = Category.arrange_as_array(order: order_by_attrib)
    new_record? ? parents : parents - subtree
  end


  def display_name_with_depth(depth_prefix: '-')
    "#{depth_prefix * depth} #{name}"
  end


  # return the total number of checklist_items + child checklists
  def num_items_and_children
    checklist_items.count + children.size
  end


  private


  def update_item_order_numbers
    # FIXME error handling for updating each ChecklistItem
    # FIXME don't update every item in the list if not needed
    item_ids_by_order_nums.each_with_index { |item_id, i| ChecklistItem.find(item_id).update(order_in_list: i) }
  end


  def item_ids_by_order_nums
    @item_ids_by_order_nums ||= checklist_items.order(:order_in_list).map(&:id)
  end

end
