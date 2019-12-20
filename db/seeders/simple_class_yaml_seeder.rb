require_relative './yaml_seeder'

#--------------------------
#
# @class Seeders::SimpleClassYamlSeeder
#
# @desc Responsibility: Read and write simple ActiveRecords from/to YAML files.
#   This is for classes that can read from a YAML Hash of information without any further manipulation.
#
# SUBCLASSES MUST DEFINE 2 CONSTANTS:
#   1. YAML_FILENAME : the base YAML filename to read the data from (and write to) Ex: 'business-categories.yml'
#   2. SEEDED_CLASS : the ActiveRecord subclass that this is going to instantiate and serialize  Ex: BusinessCategory
#
#
# @examples
#   Given a seeder class named SomeSimpleARModelSeeder where:
#     - it is a subclass of this class (e.g. class SomeARModelSeeder < SimpleClassYamlSeeder )
#     - it has the 2 required constants defined as needed, e.g.
#       - YAML_FILENAME = 'some-ar-model-data.yml'
#       - SEEDED_CLASS = SomeSimpleARModel # this is the AR Model class with objects we want to seed/read/write
#
#     The BusinessCategoriesSeeder class  is very simple.  It just has the 2 constants defined.
#     No methods are needed.
#     Here is the entire BusinessCategoriesSeeder class definition:
#
#       require_relative './simple_class_yaml_seeder'
#       module Seeders
#         class BusinessCategoriesSeeder < SimpleClassYamlSeeder
#           YAML_FILENAME = 'business-categories-data.yml'
#           SEEDED_CLASS = BusinessCategory
#         end
#       end
#
#
#     To write out everything currently in the database:
#       Seeders::BusinessCategoriesSeeder.write_yaml
#
#     To seed information (read information in from the YAML_FILENAME and save in the database):
#       Seeders::BusinessCategoriesSeeder.seed
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/15/19
#
#--------------------------

module Seeders

  class SimpleClassYamlSeeder < YamlSeeder

    # SUBCLASSES MUST DEFINE THIS. IT MUST BE AN ActiveRecord class. EX: BusinessCategory
    #    class String is used here just as a placeholder and so that the appropriat errors/exceptions will be raised if a subclass does not define this.
    SEEDED_CLASS = String

    ATTRIBS_TO_REMOVE = [:id, :created_at, :updated_at].freeze

    # Create a SEEDED_CLASS instance and save it in the database
    # Do _not_ save the id, created_at, or updated_at information that might be in the yaml entry.
    # These attributes should be newly created when the instance is saved.
    #
    # @return [<SEEDED_CLASS>] - the object created
    #
    def self.create_object(yaml_entry)
      seeded_class.create!(stripped_attribs(yaml_entry))
    end


    # @return [Array[Hash]] - all of serialized objects as a serialzed Hash (YAML)
    #
    def self.serialized_objects
      seeded_class.all.map(&:serializable_hash)
    end


    def self.stripped_attribs(orig_attribs)
      stripped_down_attribs = orig_attribs.dup
      ATTRIBS_TO_REMOVE.each { |attrib_to_remove| stripped_down_attribs.delete(attrib_to_remove) }
      stripped_down_attribs
    end


    def self.seeded_class
      self::SEEDED_CLASS
    end


  end
end
