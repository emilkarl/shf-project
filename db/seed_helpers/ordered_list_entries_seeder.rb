require 'yaml'

module SeedHelper

#--------------------------
#
# @class OrderedListEntriesSeeder
#
# @desc Responsibility: Seed checklists, their items and sub-checklists from a YAML file
#   Can also write hardcoded data out to the YAML file. (can write out and read in)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-29
#
#--------------------------
  class OrderedListEntriesSeeder

    ORDEREDLISTENTRIES_YAML_SOURCE = File.join(__dir__, 'ordered-list-entries.yml')


    def self.seed
      yaml_entries = read_yaml
      yaml_entries.each { |yaml_entry| create_entry_and_children(yaml_entry) }
    end


    # Create an OrderedListEntry from the yaml_hash, then each entry in [:children] (this recurses top-down)
    def self.create_entry_and_children(yaml_hash, parent_ordered_entry: nil)

      new_ordered_entry = create_ordered_entry(yaml_hash, parent_ordered_entry: parent_ordered_entry)

      yaml_hash[:children].each do |yaml_child_entry|
        create_entry_and_children(yaml_child_entry, parent_ordered_entry: new_ordered_entry)
      end
    end


    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil)
      OrderedListEntry.create!(name: yaml_entry[:name],
                               description: yaml_entry[:description],
                               list_position: yaml_entry[:list_position],
                               parent: parent_ordered_entry)
    end


    # @return [Hash] - the information read from the source file using YAML.load
    def self.read_yaml(source_file_path = ORDEREDLISTENTRIES_YAML_SOURCE)
      YAML.load(File.read(source_file_path), symbolize_names: true)
    end


    def self.write_yaml
      create_ordered_entries_to_write
      write_to_yaml_source(serialized_order_entries)
    end


    def self.create_ordered_entries_to_write
      create_ethical_guidelines
      create_membership_steps
    end


    def self.serialized_ordered_entries
      OrderedListEntry.arrange_serializable
    end


    # Write out OrderedListEntries to the source YAML file
    # @return [String] - the file name written to
    def self.write_to_yaml_source(serialized_str = '', source_filename = ORDEREDLISTENTRIES_YAML_SOURCE)
      File.open(source_filename, "w") { |file| file.write(serialized_str.to_yaml) }

      source_filename
    end


    # ==========================
    # Create OrderedListEntries
    #   Instantiate and save entries (e.g. so they can then be serialized to create a .yml file)

    def self.create_ethical_guidelines

      guidelines_list = OrderedListEntry.create!(name: 'Ethical Guidelines for members', description: 'SHF Member Ethical Guidelines')

      OrderedListEntry.create!(name: 'Respect the Dog',
                               description: '... something about this',
                               parent: guidelines_list,
                               list_position: 0)

      OrderedListEntry.create!(name: 'Respect the Owner',
                               description: '... something about this',
                               parent: guidelines_list,
                               list_position: 1)

      OrderedListEntry.create!(name: 'Follow all laws',
                               description: '... something about this',
                               parent: guidelines_list,
                               list_position: 2)
      guidelines_list
    end


    def self.create_membership_steps


      membership_steps = OrderedListEntry.create!(name: 'Membership steps', description: 'Steps to become a member')

      registration_steps = create_registration_steps
      registration_steps.update(parent: membership_steps, list_position: 0)

      application_steps = create_application_steps
      application_steps.update(parent: membership_steps, list_position: 1)

      OrderedListEntry.create!(name: 'SHF has approved your application', description: 'SHF has reviwed and approved your application.',
                               parent: membership_steps,
                               list_position: 2)

      OrderedListEntry.create!(name: 'Pay your membership fee', description: 'pay your membership fee',
                               parent: membership_steps,
                               list_position: 3)

      membership_steps
    end


    def self.create_application_steps

      application_steps = OrderedListEntry.create!(name: 'Steps to complete an application', description: 'Steps to complete an application for joining SHF')

      OrderedListEntry.create!(name: 'Provide your org nummber', description: 'Provide the Org nummer (company number)',
                               parent: application_steps,
                               list_position: 0)
      OrderedListEntry.create!(name: 'Business categories', description: 'Check at least 1 business category',
                               parent: application_steps,
                               list_position: 1)
      OrderedListEntry.create!(name: 'Documents', description: 'Provide documents that show your certifications for the buisness categories',
                               parent: application_steps,
                               list_position: 2)

      application_steps
    end


    def self.create_registration_steps

      registrations_steps = OrderedListEntry.create!(name: 'Register as a user', description: 'Provide information needed to register.')

      OrderedListEntry.create!(name: 'email', description: 'Provide a valid email address for logging in.',
                               parent: registrations_steps,
                               list_position: 0)
      OrderedListEntry.create!(name: 'password', description: 'Create a password for logging in.',
                               parent: registrations_steps,
                               list_position: 1)
      registrations_steps
    end

  end

end
