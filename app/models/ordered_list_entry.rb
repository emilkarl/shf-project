#--------------------------
#
# @class OrderedListEntry
#
# @desc Responsibility:
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date
#
#--------------------------

class OrderedListEntry < ApplicationRecord

  has_ancestry

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


  # Inserts the given item into children before the element with the given +index+.
  # If no index is given, append the item at the end. (index = -1)
  # index is used in the same way as Array#insert
  # See Array#insert for details
  #
  # After the insert, update the order_in_list [= position] for all children.
  #
  # @param new_position [Integer] - the 0-based position for the new entry.  Default = the size of the list of children,  which will place the new_entry at the end
  # @param new_entry [OrderedListEntry] - the new entry to insert into the list of children
  #
  def insert(new_entry, new_position = children.size)
    increment_child_positions(new_position)
    new_entry.update(list_position: new_position, parent: self)
  end


  # Append a new entry to the end of the list of children
  #
  # @param new_entry [OrderedListEntry] - the new entry to insert into the list of children
  #
  def <<(new_entry)
    insert(new_entry)
  end


  # Delete the OrderedListEntry from the list of children.
  # After the deletion, update the positions for all children as necessary.
  #
  # @param entry [OrderedListEntry] - the entry to delete from the list of children
  #
  def delete(entry)
    if children.include?(entry)
      children.delete(entry)
      decrement_child_positions(entry.list_position)
    end
  end


  def display_name_with_depth(depth_prefix: '-')
    "#{depth_prefix * depth} #{name}"
  end


  private


  def increment_child_positions(position_start = children.size)
    children_to_increment = children.select { |child| child.list_position >= position_start }
    children_to_increment.each { |child| child.update(list_position: child.list_position + 1) }
  end


  def decrement_child_positions(position_start = 0)
    # do not decrement any list_position that is zero or less
    children_to_increment = children.select { |child| child.list_position > 0 && (child.list_position >= position_start) }
    children_to_increment.each { |child| child.update(list_position: child.list_position - 1) }
  end

end
