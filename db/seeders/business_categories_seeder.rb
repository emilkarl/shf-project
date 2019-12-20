require_relative './simple_class_yaml_seeder'

module Seeders
  #--------------------------
  #
  # @class BusinessCategoriesSeeder
  #
  # @desc Responsibility: Seed BusinessCategories to/from a YAML file
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/15/19
  #
  #--------------------------
  #
  class BusinessCategoriesSeeder < SimpleClassYamlSeeder

    YAML_FILENAME = 'business-categories-data.yml'
    SEEDED_CLASS = BusinessCategory

  end

end
