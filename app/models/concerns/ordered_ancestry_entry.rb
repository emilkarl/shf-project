require 'active_support/concern'
#require 'ancestry'

#--------------------------
#
# @module OrderedAncestryEntry
#
# @desc Responsibility: Abstract class for objects with _ordered_ nested
# descendents using the ancestry gem.``
# Ordering the descendents is the main difference between this and a 'typical'
# class that uses the ancestry gem.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/21/19
#
#--------------------------


module OrderedAncestryEntry

  extend ActiveSupport::Concern

  included do

    # If the list position has changed,
    # the parent (containing) list needs to update all of the other entries (siblings) in the list.
    around_update :update_parent_list_positions, if: :will_save_change_to_list_position?


    # --------------------------------------------------------------------------

    # Return the entry and all descendents as an Array, sorted by ancestry,
    #   list position and then any additional attributes passed in as arguments.
    #
    # Helpful for displaying the list.
    #
    # @param [Array<String>] order - list of attributes to order the array by
    # @return [Array<OrderedListEntry>] - an Array with the given node first, then its descendents sorted by the ancestry, list position, and then name.
    #
    def self.all_as_array(order: [])
      arrange_as_array(order: %w(ancestry list_position).concat(order))
    end


    # Arrange the hash of nodes and all descendents as an Array. Sort based on the options given.
    # If no hash of nodes is given, arrange all OrderedListEntries
    # Recurse depth first through all descendents.
    #
    # @param [Hash] options - options given to Ancestry.arrange. options[:order] will be used for sorting/order_by
    # @param [Hash] nodes_to_arrange_hash - a Hash of nodes to arrange. Initialized to Ancestry.arrange(options) if not given.
    #
    # @return [Array<OrderedListEntry>] - an Array with the given node first, then its descendents sorted based on options[:order]
    #
    def self.arrange_as_array(options = {}, nodes_to_arrange_hash = nil)
      nodes_to_arrange_hash ||= arrange(options)
      arr = []
      nodes_to_arrange_hash.each do |node, children|
        arr << node
        arr += arrange_as_array(options, children) unless children.nil?
      end
      arr
    end


    # Inserts the given entry into children before the element with the given +index+.
    # If no index is given, append the entry at the end. (index = -1)
    # index is used in the same way as Array#insert
    # See Array#insert for details
    #
    # After the insert, update the order_in_list [= position] for all children.
    #
    # @param new_position [Integer] - the 0-based position for the new entry.
    #  Default = the size of the list of children,  which will place the new_entry at the end
    # @param new_entry [OrderedListEntry] - the new entry to insert into the list of children
    #
    # @return [Array] - children with the new entry inserted
    def insert(new_entry, new_position = children.size)
      increment_child_positions(new_position)
      new_entry.update(list_position: new_position, parent: self)
    end


    alias_method :<<, :insert


    # Delete the OrderedListEntry from the list of children.
    # After the deletion, update the positions for all children as necessary.
    #
    # @param entry [OrderedListEntry] - the entry to delete from the list of children
    # @return [Array] - children with the entry deleted
    def delete(entry)
      if children.include?(entry)
        children.delete(entry)
        decrement_child_positions(entry.list_position)
      end
      children
    end


    # Delete the child at the zero-based position
    # This must be done BEFORE db changes are written
    #   else we cannot get the child by list_position because it will have already been changed.
    #
    # @return [Array] - children with the entry deleted
    def delete_child_at(position = children.size)
      unless position >= children.size
        deleted_child = child_at_position(position)
        children.delete(deleted_child)
        decrement_child_positions(position)
      end
      children
    end


    # the next list position that should be used
    def next_list_position
      children.size
    end


    def child_at_position(position)
      return unless children?
      children.select { |child| child.list_position == position }.first
    end


    # Return a list of all entries that could be parent to this entry.
    # The entry cannot be a parent to itself
    # No children of this entry can be a parent
    # Helpful for selecting a parent for an entry
    #
    # @param [Array[OrderedListEntry]] - list of entries to check
    # @return [Array[OrderedListEntry]] - the list of entries that can be a parent to this object
    def allowable_as_parents(potential_parents = [])
      return potential_parents if potential_parents.empty?

      if self.persisted?
        allowable_parents = potential_parents.reject { |potential_parent| potential_parent.id == id }

        if children? # children only exist once ancestry has been created during a save
          children_ids = children.map(&:id)
          allowable_parents = allowable_parents.reject { |potential_parent| children_ids.include?(potential_parent.id) }
        end

      else
        allowable_parents = potential_parents
      end

      allowable_parents
    end


    # =============================
    protected


    # This calls update_columns (_not_ update) so that any update... callbacks will NOT be triggered
    def increment_child_positions(position_start = children.size)
      children_to_increment = children_to_increment(position_start)
      children_to_increment.each do |child|
        child.update_list_position_and_updated_cols(child.list_position + 1)
      end
    end


    # This calls update_columns (_not_ update) so that any update... callbacks will NOT be triggered
    def decrement_child_positions(position_start = children.size)
      children_to_decrement = children_to_decrement(position_start)
      children_to_decrement.each do |child|
        child.update_list_position_and_updated_cols(child.list_position - 1)
      end
    end


    # Update list_position and updated_at in memory
    # Use update_columns(...) to update only those columns in the db so that
    # callbacks and validations are _not_ called
    def update_list_position_and_updated_cols(new_list_pos)
      updated_at = Time.current
      update_columns(list_position: new_list_pos, updated_at: updated_at)
    end


  end


  # =============================
  private


  # Update the list positions for all entries in the parent list based on
  # the about to be saved 'list_position' attribute for this entry.
  # See around_update
  #
  # This is not the most efficient way to do this, but it is the most straightforward.
  # (If the list lengths were very large, it would be worth using a more efficient algorithm.)
  #
  def update_parent_list_positions

    if ancestors?
      original_list_position = attribute_change_to_be_saved('list_position').first
      new_position = attribute_change_to_be_saved('list_position').last

      # move all children "down" to fill where this entry used to be
      parent.decrement_child_positions(original_list_position + 1)

      # make room for where this will be inserted in the new_position
      parent.increment_child_positions(new_position)

      # update and save this object
      yield
    end
  end


  def children_to_increment(position_start = children.size)
    position_to_start_incrementing = position_start.blank? ? children.size : position_start
    children.select { |child| child.list_position >= position_to_start_incrementing }
  end


  def children_to_decrement(position_start = children.size)
    position_to_start_decrementing = position_start.blank? ? children.size : position_start

    # do not decrement any list_position that is zero or less
    children.select { |child| child.list_position > 0 && child.list_position >= position_to_start_decrementing }
  end

end
