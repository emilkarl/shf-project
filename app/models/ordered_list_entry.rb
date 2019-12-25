require 'ordered_ancestry_entry'

#--------------------------
#
# @class OrderedListEntry
#
# @desc Responsibility: A checklist entry that has _ordered_ children and
# (possibly) a position in an ordered list.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date 2019-12-01
#
#--------------------------

class OrderedListEntry < ApplicationRecord

  validates_presence_of :name
  validates_presence_of :list_position


  has_ancestry

  include OrderedAncestryEntry

  # --------------------------------------------------------------------------

  # Return the entry and all children as an Array, sorted by list position and then name.
  #
  # @return [Array<OrderedListEntry>] - an Array with the given node first, then its children sorted by the ancestry, list position, and then name.
  #
  def self.all_as_array_nested_by_name
    all_as_array(order: %w(name))
  end


  # @param [String] prefix - the string that represents one level of depth; is
  #   prepended :depth times in front of the name
  # @return [String] - a string showing the depth of this entry and the name
  def display_name_with_depth(prefix: '-')
    "#{prefix * depth} #{name}"
  end

end
