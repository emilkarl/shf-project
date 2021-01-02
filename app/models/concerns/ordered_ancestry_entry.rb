require 'active_support/concern'

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
    before_update :update_parent_list_positions, if: :will_save_change_to_list_position?


    NO_CHILDREN_LAST_USED_POSITION = -1 unless defined?(NO_CHILDREN_LAST_USED_POSITION)

    # --------------------------------------------------------------------------

    # Return the entry and all descendents as an Array, sorted by ancestry,
    #   list position and then any additional attributes passed in as arguments.
    #
    # Helpful for displaying the list.
    #
    # @param [Array<String>] order - list of attributes to order the array by
    # @return [Array<OrderedAncestryEntry>] - an Array with the given node first, then its descendents sorted by the ancestry, list position, and then name.
    #
    def self.all_as_array(order: [])
      arrange_as_array(order: %w(ancestry list_position).concat(order))
    end


    # Arrange the hash of nodes and all descendents as an Array. Sort based on the options given.
    # If no hash of nodes is given, arrange all instances of this class (the including class of this module)
    # Recurse depth first through all descendents.
    #
    # @param [Hash] options - options given to Ancestry.arrange. options[:order] will be used for sorting/order_by
    # @param [Hash] nodes_to_arrange_hash - a Hash of nodes to arrange. Initialized to Ancestry.arrange(options) if not given.
    #
    # @return [Array<OrderedAncestryEntry>] - an Array with the given node first, then its descendents sorted based on options[:order]
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
    # @param new_entry [OrderedAncestryEntry] - the new entry to insert into the list of children
    # @param new_position [Integer] - the 0-based position for the new entry.
    #  Default = the size of the list of children,  which will place the new_entry at the end
    #
    # @return [OrderedAncestryEntry] - children with the new entry inserted
    def insert(new_entry, new_position = children.size)
      increment_child_positions(new_position)
      new_entry.update(list_position: new_position, parent: self)
    end

    alias_method :insert_in_children, :insert

    alias_method :<<, :insert


    def sorted_siblings
      siblings.order(list_position: :asc)
    end


    def next_sibling?
      siblings? && next_sibling
    end


    alias_method :has_next_sibling?, :next_sibling?


    def next_sibling
      if siblings?
        sorted_sibs = sorted_siblings.to_a
        this_index = this_index_in_sorted_sibs(sorted_sibs)
        # if the next index (this_index + 1) is more than the size of the siblings,
        #   then there isn't a next sibling
        #   else return the next sibling
        (this_index + 1 > sorted_sibs.count - 1) ? nil : sorted_sibs[this_index + 1]
      end
    end


    def this_index_in_sorted_sibs(sorted_sibs = sorted_siblings.to_a)
      sorted_sibs.find_index { |sib| sib.list_position == list_position }
    end


    def previous_sibling?
      siblings? && previous_sibling
    end


    alias_method :has_previous_sibling?, :previous_sibling?


    def previous_sibling
      if siblings?
        sorted_sibs = sorted_siblings.to_a
        this_index = this_index_in_sorted_sibs(sorted_sibs)
        # if the previous index (this_index - 1) is less than 0
        #   then there isn't a previous sibling
        #   else return the previous sibling
        (this_index - 1 < 0) ? nil : sorted_sibs[this_index - 1]
      end
    end


    # This method will eventually be available in the Ancestry gem. (and/or a SQL based version)
    # Until then, here it is.
    def leaves
      subtree.select { |node| node.childless? }
    end


    # Delete the entry from the list of children.
    # After the deletion, update the positions for all children as necessary.
    #
    # @param entry [OrderedAncestryEntry] - the entry to delete from the list of children
    # @return [Array] - children with the entry deleted
    def delete_from_children(entry)
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


    # The last (max) list_position of all children.
    # Is -1 if there are no children
    def last_used_list_position
      children? ? children.map(&:list_position).max : NO_CHILDREN_LAST_USED_POSITION
    rescue Ancestry::AncestryException
      # if this has not yet been saved, Ancestry will raise this exception.
      # No need to propagate the exception. Return the value for having no children.
      NO_CHILDREN_LAST_USED_POSITION
    end


    # the next list position that should be used
    def next_list_position
      last_used_list_position + 1
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
    # List is sorted by list_position by default.
    #
    # @param [Array<OrderedAncestryEntry>] - list of entries to check
    # @param  [Proc] block - a block to pass to #sort_by used to sort the final list returned
    # @return [Array<OrderedAncestryEntry>] - the list of entries that can be a parent to this object
    #
    def allowable_as_parents(potential_parents = [], &block)
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

      block ? allowable_parents.sort_by(&block) : allowable_parents
    end


    # =============================
    protected


    # This calls update_columns (_not_ update) so that any update... callbacks will NOT be triggered
    def increment_child_positions(position_start = children.size)
      children_to_inc = children_to_increment(position_start)
      increment_positions(children_to_inc)
    end


    # This calls update_columns (_not_ update) so that any update... callbacks will NOT be triggered
    def decrement_child_positions(position_start = children.size)
      children_to_dec = children_to_decrement(position_start)
      decrement_positions(children_to_dec)
    end


    # Update list_position and updated_at in memory
    # Uses update_columns(...) to update only those columns in the db so that
    # callbacks and validations are _not_ called
    def update_list_position_and_updated_cols(new_list_pos)
      updated_at = Time.current
      update_columns(list_position: new_list_pos, updated_at: updated_at)
    end


    # =============================
    private


    # Update the list positions for all entries in the parent list based on
    # the about to be saved 'list_position' attribute for this entry.
    # If this is a top level list and the position has changed, then update the
    # list positions for all other top level lists ( = siblings ).
    #
    #
    # See before_update
    #
    # This is not the most efficient way to do this, but it is the most straightforward.
    # (If the list lengths were very large, it would be worth using a more efficient algorithm.)
    #
    def update_parent_list_positions
      original_list_position = attribute_change_to_be_saved('list_position').first
      new_position = attribute_change_to_be_saved('list_position').last

      if ancestors?
        # move all children "down" to fill where this entry used to be
        parent.decrement_child_positions(original_list_position + 1)

        # make room for where this will be inserted in the new_position
        parent.increment_child_positions(new_position)
      else
        # If this is a top level list, need to update all siblings
        if siblings?
          sibs_not_including_self = siblings.reject { |s| s == self }
          sibs_after_orig_position = entries_to_decrement(sibs_not_including_self, original_list_position + 1)
          decrement_positions(sibs_after_orig_position)

          sibs_to_increment = entries_to_increment(sibs_not_including_self, new_position)
          increment_positions(sibs_to_increment)
        end
      end
    end


    def decrement_positions(entries_to_decrement = [])
      entries_to_decrement.each do |entry|
        entry.update_list_position_and_updated_cols(entry.list_position - 1)
      end
    end


    def increment_positions(entries_to_increment = [])
      entries_to_increment.each do |entry|
        entry.update_list_position_and_updated_cols(entry.list_position + 1)
      end
    end


    def children_to_increment(position_start = children.size)
      entries_to_increment(children, position_start)
    end


    def children_to_decrement(position_start = children.size)
      entries_to_decrement(children, position_start)
    end


    def entries_to_increment(entries = [], position_start)
      position_to_start_incrementing = position_start.blank? ? entries.size : position_start
      entries.select { |entry| entry.list_position >= position_to_start_incrementing }
    end


    def entries_to_decrement(entries = [], position_start)
      position_to_start_decrementing = position_start.blank? ? entries.size : position_start
      # do not decrement any list_position that is zero or less
      entries.select { |entry| entry.list_position > 0 && entry.list_position >= position_to_start_decrementing }
    end

  end

end
