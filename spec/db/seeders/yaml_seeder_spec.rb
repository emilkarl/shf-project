require 'spec_helper'

# Use this so that we don't have to load Rails just to run this
require_relative File.join(__dir__, '../../../db/seeders/yaml_seeder')


RSpec.describe Seeders::YamlSeeder do

  EXAMPLE_YAML_FILES_DIR = '../../fixtures/db/seeders/yaml-data'

  # don't let the described_class puts any messages (Shush the class by stubbing :tell)
  before { allow(described_class).to receive(:tell) }


  def new_yml_tempfile
    Tempfile.new(['temp-yaml-out', '.yml'])
  end


  # Use this instead of the Rails RSpec :file_fixture method so we don't have to load Rails to run this
  def example_file_path(base_filename)
    File.join(__dir__, EXAMPLE_YAML_FILES_DIR, base_filename)
  end


  describe '.seed' do

    it 'default source file is (File.join(YAML_PATH, YAML_FILENAME)' do
      expect(described_class).to receive(:read_yaml).and_return([])
      described_class.seed
    end

    it 'reads from the yaml data file' do
      expect(described_class).to receive(:read_yaml).and_return([])
      described_class.seed
    end

    it 'calls create_objects to instantiate objects read in from the YAML file' do
      allow(described_class).to receive(:read_yaml).and_return([])
      expect(described_class).to receive(:create_objects).with([]).and_call_original
      described_class.seed
    end

    it 'returns a list of objects created' do
      allow(described_class).to receive(:read_yaml).and_return([])
      allow(described_class).to receive(:create_objects).with([]).and_call_original

      expect(described_class.seed).to be_a Array
    end

    it 'puts a message about the number of objects seeded' do
      allow(described_class).to receive(:read_yaml).and_return([])
      allow(described_class).to receive(:create_objects).with([]).and_return([String.new])

      expect(described_class).to receive(:tell_num_objects_created).and_call_original
      described_class.seed
    end

    it 'if zero objects are seeded, it puts message includes a warning' do
      allow(described_class).to receive(:read_yaml).and_return([])
      allow(described_class).to receive(:create_objects).with([]).and_return([])

      expect(described_class).to receive(:tell_zero_objects_created_warning).and_call_original
      described_class.seed
    end
  end


  describe '.read_yaml' do

    it 'default source file is (File.join(YAML_PATH, YAML_FILENAME)' do
      allow(YAML).to receive(:load).and_return([])
      expect(File).to receive(:read).with(File.join(described_class.yaml_path, described_class.yaml_filename)).and_return('[]')

      described_class.read_yaml
    end


    describe 'returns a Hash from YAML.load' do

      describe 'per YAML.load results' do

        describe 'returns an empty list if YAML.load returns an empty list' do

          it "yaml file only has '[]'" do
            array_brackets_only_yaml_fn = example_file_path('array-brackets-only-yaml-data.yml')
            expect(described_class.read_yaml(array_brackets_only_yaml_fn)).to be_empty
          end

          it "yaml file has '[]' after the YAML header ('---')" do
            array_brackets_only_yaml_fn = example_file_path('array-brackets-after-yaml-header-yaml-data.yml')
            expect(described_class.read_yaml(array_brackets_only_yaml_fn)).to be_empty
          end
        end

        describe 'raises a Seeders::YamlSeederError if YAML.load fails (returns nil or false)' do

          it 'yaml file has a syntax error' do
            # fixtures is spec/fixtures/uploaded_files
            bad_yaml_fn = example_file_path('bad-yaml-data.yml')
            expect { described_class.seed(bad_yaml_fn) }.to raise_exception(Seeders::YamlSeederError, //)
          end

          it 'yaml file is empty' do
            # fixtures is spec/fixtures/uploaded_files
            empty_yaml_fn = example_file_path('empty-yaml-data.yml')
            expect { described_class.seed(empty_yaml_fn) }.to raise_exception(Seeders::YamlSeederError, //)
          end

          it 'yaml file only has comments after YAML header' do
            comments_only_yaml_fn = example_file_path('comments-only-yaml-data.yml')
            expect { described_class.seed(comments_only_yaml_fn) }.to raise_exception(Seeders::YamlSeederError, //)
          end

          it "yaml file only has YAML header ('---')" do
            yaml_header_only_yaml_fn = example_file_path('yaml-header-only-yaml-data.yml')
            expect { described_class.seed(yaml_header_only_yaml_fn) }.to raise_exception(Seeders::YamlSeederError, //)
          end

        end
      end

    end
  end


  describe '.create_objects' do

    it 'calls create_object to create each object' do
      faux_entries = [{ name: 'first' },
                      { name: 'second' }]

      expect(described_class).to receive(:create_object).twice
      described_class.create_objects(faux_entries)
    end
  end


  describe '.create_object' do

    it 'subclasses MUST define :create_object to instantiate each object' do
      expect { described_class.create_object('') }.to raise_exception(NoMethodError, 'Subclass must define the create_object method')
    end


    #describe 'saves the objects in the database' do
    #
    #  it 'count is increased' do
    #    pending 'TBD'
    #  end
    #
    #  it 'saves any associated objects as needed' do
    #    pending 'TBD'
    #  end
    #
    #  it 'ignores any database ids (primary keys) that are read in; new ones are created on save to db' do
    #    pending 'TBD'
    #  end
    #
    #  it 'does not try to identify or with duplicates; that is left to humans or subclasses' do
    #    pending 'TBD'
    #  end
    #
    #end

  end


  describe '.write_yaml' do

    it 'gets the filename to write out to' do
      temp_file = new_yml_tempfile

      begin
        allow(described_class).to receive(:serialized_objects).and_return('# YAML for objects written out here')
        expect(described_class).to receive(:yaml_output_filename).and_call_original

        described_class.yaml_output_filename(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))
      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

    it 'returns the full filename (includes path) of the file written out to' do

      temp_file = new_yml_tempfile
      begin
        allow(described_class).to receive(:serialized_objects).and_return("# YAML for objects written out here\n")

        output_fn = described_class.write_yaml(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))
        temp_dir = File.dirname(temp_file)
        temp_justfilename = File.basename(temp_file, '.yml')
        expect(output_fn).to match(/#{File.join(temp_dir, temp_justfilename)}.*\.yml/) # allow for a timestamp in there

      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

    it 'first line is the YAML file indicator' do
      temp_file = new_yml_tempfile

      begin
        allow(described_class).to receive(:serialized_objects).and_return("# YAML for objects written out here\n")

        output_fn = described_class.write_yaml(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))

        contents = ''
        File.open(output_fn, "r") { |f| contents = f.readlines }

        expect(contents.first).to eq("---\n")
      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

    it 'writes comments at the top so humans have hints about data in this file' do
      temp_file = new_yml_tempfile
      begin
        allow(described_class).to receive(:serialized_objects).and_return("# YAML for objects written out here\n")
        expect(described_class).to receive(:top_comments).and_call_original

        described_class.write_yaml(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))

      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

    it 'writes the serialized_objects string out to the yaml file' do
      temp_file = new_yml_tempfile
      begin
        expect(described_class).to receive(:serialized_objects).and_return("# YAML for objects written out here")

        described_class.write_yaml(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))

      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

    it 'subclasses must implement their own version of :serialized_objects' do
      temp_file = new_yml_tempfile
      begin
        expect { described_class.write_yaml(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file)) }.to raise_exception(NoMethodError, 'Subclass must define the serialized_objects method')

      ensure
        temp_file.close
        temp_file.unlink # deletes the temp file
      end
    end

  end


  describe '.yaml_output_filename' do

    it 'default is File.join(default yaml directory, YAML_FILENAME)' do
      expect(described_class.yaml_output_filename).to match(/#{described_class.yaml_path}\/#{File.basename(described_class.yaml_filename, '.yml')}.*\.yml/)
    end

    context 'yaml filename already exists' do

      it 'appends the timestamp to the YAML_FILENAME' do
        temp_file = new_yml_tempfile

        begin
          expect(described_class).to receive(:timestamped_fn).once

          described_class.yaml_output_filename(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))
        ensure
          temp_file.close
          temp_file.unlink # deletes the temp file
        end
      end

      it 'shows a warning that the file ready exists' do
        temp_file = new_yml_tempfile

        begin
          expect(described_class).to receive(:tell_file_already_exists)

          described_class.yaml_output_filename(basefn: File.basename(temp_file), dir_path: File.dirname(temp_file))
        ensure
          temp_file.close
          temp_file.unlink # deletes the temp file
        end
      end
    end

    context 'yaml filename does not exist' do

      it 'returns File.join(<directory>, YAML_FILENAME)' do
        expect(described_class.yaml_output_filename(dir_path: Dir.tmpdir)).to match(/#{Dir.tmpdir}\/#{described_class.yaml_filename}/)
      end
    end
  end


  describe '.top_comments' do

    it 'returns a string to write to the top of the yaml file' do
      expect(described_class.top_comments).to be_a String
    end

    it 'is the standard top comments, then additional top comments, then a separator line' do
      expect(described_class).to receive(:standard_top_comments).once.and_call_original
      expect(described_class).to receive(:additional_top_comments).once.and_call_original
      expect(described_class).to receive(:comment_separator_line).once.and_call_original

      described_class.top_comments
    end
  end


  describe '.standard_top_comments' do

    it 'writes the project information line' do
      expect(described_class.standard_top_comments).to match(/YAML Seed data for the SHF project/)
    end

    it 'write YAML data for: <this class name>' do
      expect(described_class.standard_top_comments).to match(/.*YAML Data for class: #{described_class.name}/)
    end

    it 'writes Date written: <timestamp>' do
      expect(described_class.standard_top_comments).to match(/Date written\: \d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d (.)*(\s)*/)
    end
  end


  describe '.additional_top_comments' do

    it 'just returns an empty string by default' do
      expect(described_class.additional_top_comments).to eq ''
    end
  end

  describe '.comment_line' do

    it 'prepends # and a space to the text given' do
      expect(described_class.comment_line('blorf')).to match(/# blorf/)
    end

    it 'appends a newline to the text given' do
      expect(described_class.comment_line('blorf')).to match(/blorf\n/)
    end
  end


  describe '.timestamped_fn' do

    it 'keeps the same file extension' do
      expect(described_class.timestamped_fn('this.blorf')).to match(/.*\.blorf/)
    end

    it 'keeps the same directory (path)' do
      expect(described_class.timestamped_fn('this/that/another/something.blorf')).to match(/this\/that\/another\//)
    end

    it 'appends a timestamp of format %F-%H%M%S%z to the filename' do
      allow(Time).to receive(:now).and_return(Time.new(2123, 1, 2, 3, 4, 5))
      expect(described_class.timestamped_fn('this.blorf')).to match(/.*this-2123-01-02-030405.*\.blorf/)
    end
  end

end

