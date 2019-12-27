require 'rails_helper'

require_relative File.join(Rails.root, 'db/seeders/ordered_list_entries_seeder')


RSpec.describe Seeders::OrderedListEntriesSeeder do

  # truncate will clear the data AND reset the id sequence to start at 1 (so the ids should be the same)
  def truncate_and_restart_id(connection, table_name)
    connection.execute("truncate table #{table_name} RESTART IDENTITY CASCADE")
  end


  it 'write_yaml, read_yaml, write_yaml is idempotent (yaml written and read == original yaml source written)' do

    # stub this method to shush YamlSeeder
    allow(Seeders::YamlSeeder).to receive(:tell)

    seeded_class = described_class::SEEDED_CLASS

    # Ensure we'll start with the first object id = 1
    truncate_and_restart_id(seeded_class.connection, seeded_class.table_name)

    create(:ordered_list_entry, name: 'entry with no children', description: 'simple entry with no children')

    parent = create(:ordered_list_entry, name: 'list with 2 children', description: 'list with 2 children')
    create(:ordered_list_entry, name: 'child 1', description: 'child 1 of the list with 2 children', list_position: 0, parent: parent)
    create(:ordered_list_entry, name: 'child 2', description: 'child 2 of the list with 2 children', list_position: 1, parent: parent)

    # Write the objects out
    yaml_output_file = Tempfile.new(['ordered-list-entry', '.yml'])
    yaml_output_filepath = yaml_output_file.path
    yaml_written_first_fn = described_class.write_yaml(basefn: File.basename(yaml_output_file), dir_path: File.dirname(yaml_output_filepath))


    # Ensure we'll start with the first object id = 1
    truncate_and_restart_id(seeded_class.connection, seeded_class.table_name)

    # Read the objects in from the file we wrote out
    described_class.seed(yaml_written_first_fn)

    # Write the objects (that we read in) out
    yaml_output_file2 = Tempfile.new(['ordered-list-entry', '.yml'])
    yaml_output_filepath2 = yaml_output_file.path
    yaml_written_second_fn = described_class.write_yaml(basefn: File.basename(yaml_output_file2), dir_path: File.dirname(yaml_output_filepath2))

    orig_read_in = File.readlines(yaml_written_first_fn)
    written_out = File.readlines(yaml_written_second_fn)

    # sanitize timestamps -- we don't care if those match
    [orig_read_in, written_out].each do |file_lines|
      file_lines.each do |line|
        line.sub!(/Date written: \d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d.*/, 'Date written: (timestamp)')
        line.sub!(/utc: &\d \d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d\.\d* Z/, 'utc: (timestamp)')
      end
    end

    expect(orig_read_in).to match(written_out)
  end

end
