require 'rails_helper'

require_relative File.join(Rails.root, 'db/seed_helpers/ordered_list_entries_seeder')


RSpec.describe SeedHelper::OrderedListEntriesSeeder do


  describe '.seed' do
    pending
  end


  describe 'reading and writing yaml' do

    # delete entries from the Hash with these keys.  Call for all children. (this is recursive)
    def delete_entries(hash_entry, keys = [])
      keys.each { |key| hash_entry.delete(key) }
      hash_entry[:children].each { |child| delete_entries(child, keys) } if hash_entry.has_key? :children

      hash_entry
    end


    it 'write_yaml, read_yaml, write_yaml is idempotent (yaml written and read == original yaml source written)' do

      original_entries = [{ :id => 86, :name => "List with 2 children", :description => "list with 2 children", :list_position => nil, :ancestry => nil, :children => [{ :id => 87, :name => "child 1", :description => "child 1 of the list with 2 children", :list_position => 0, :ancestry => "86", :children => [] }, { :id => 88, :name => "child 2", :description => "child 2 of the list with 2 children", :list_position => 1, :ancestry => "86", :children => [] }] }, { :id => 92, :name => "entry with no children", :description => "simple entry with no children", :list_position => 0, :ancestry => nil, :children => [] }]

      yaml_output_file = Tempfile.new(['ordered-list-entry', '.yml'])
      yaml_output_filepath = yaml_output_file.path

      described_class.write_to_yaml_source(original_entries, yaml_output_filepath)
      read_yaml = described_class.read_yaml(yaml_output_filepath)

      yaml_output_file.close! # close and unlink the temporary file

      # ignore create_at and updated_at
      # remove all :created_at and :updated_at keys from entries and their children
      keys_to_delete = [:created_at, :updated_at]
      read_yaml.each do |y_entry|
        delete_entries(y_entry, keys_to_delete)
      end

      expect(read_yaml).to match_array original_entries
    end

  end


end
