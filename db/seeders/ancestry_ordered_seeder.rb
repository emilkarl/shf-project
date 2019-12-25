require 'yaml'
require_relative 'yaml_seeder'

module Seeders

#--------------------------
# TODO - make this a module?
#
# @class AncestryOrderedSeeder
#
# @desc Responsibility: Abstract class for seeding and writing classes that
#   are ordered ancestry entries.
#
# Subclasses MUST:
#   1. define YAML_FILENAME : the base YAML filename to read the data from (and write to)
#   2. define SEEDED_CLASS : the ActiveRecord subclass that this is going to instantiate and serialize  Ex: BusinessCategory
#   3. implement the create_object(_yaml_entry) method to instantiate each YAML entry (for seeding and reading objects)
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-29
#
#--------------------------
  class AncestryOrderedSeeder < YamlSeeder

    # Subclasses must define this as a [String] filename:
    YAML_FILENAME = nil

    # Subclasses must define this as the ActiveRecord class that will be seeded/will write out from
    SEEDED_CLASS = nil


    def self.create_objects(yaml_entries)
      created_objects = []
      yaml_entries.each { |yaml_entry| created_objects.concat create_entry_and_children(yaml_entry) }
      created_objects
    end


    # Create an OrderedListEntry from the yaml_hash, then each entry in [:children] (this recurses top-down)
    #
    # @return [Array<SEEDED_CLASS>] - list of the entry and children created
    def self.create_entry_and_children(yaml_hash, parent_ordered_entry: nil)

      entries_created = []
      new_ordered_entry = create_ordered_entry(yaml_hash, parent_ordered_entry: parent_ordered_entry)
      entries_created << new_ordered_entry

      yaml_hash.fetch(:children, []).each do |yaml_child_entry|
        entries_created.concat(create_entry_and_children(yaml_child_entry, parent_ordered_entry: new_ordered_entry))
      end
      entries_created
    end


    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil)
      raise NoMethodError, "Subclass must define the #{__method__} method", caller

      # Example of how a subclass might implement this method:
      # self::SEEDED_CLASS.create!(user: yaml_entry[:user],
      #                     checklist: yaml_entry[:checklist],
      #                     date_completed: yaml_entry[:date_completed],
      #                     list_position: yaml_entry[:list_position] ? yaml_entry[:list_position] : 0,
      #                     parent: parent_ordered_entry)
    end


    # @return [String] - all serialized objects in YAML form (object as a serialized YAML string),
    #   with nested children (all descendents), ordered by ancestry and then list_position.
    #
    def self.serialized_objects
      self::SEEDED_CLASS.arrange_serializable(order: [:ancestry, :list_position])
    end

  end

end
