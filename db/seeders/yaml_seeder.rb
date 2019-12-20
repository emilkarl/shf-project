require 'yaml'

module Seeders

  class YamlSeederError < StandardError
  end

  #--------------------------
  #
  # @class YamlSeeder
  #
  # @desc Responsibility: Provide the basic implementation to
  #   read data from a YML file and write data to a YML file for seeding.
  #
  # Subclasses classes MUST:
  #   1. define the base YAML filename to read the data from (and write to)
  #      this is the YAML_FILENAME constant
  #
  #   2. implement the create_object(_yaml_entry) method to instantiate each YAML entry (for seeding and reading objects)
  #   3. implement the serialized_objects method to create a String for writing to a YAML file (for writing)
  #
  #
  # Subclasses might want to also implement the create_objects method if instantiating objects is complex.
  #
  # Note that any exception handling is the responsibility of the caller.
  #
  # @examples
  #   Given a seeder class named SomeARModelSeeder where:
  #     - it is a subclass of this class (e.g. class SomeARModelSeeder < YamlSeeder )
  #     - it has the methods and constants defined as needed, e.g.
  #       - YAML_FILENAME = 'some-ar-model-data.yml'
  #       - create_object(yaml_entry) method is implemented
  #       - serialized_objects method is implemented
  #
  #     To write out everything currently in the database:
  #       Seeders::SomeARModelSeeder.write_yaml
  #
  #     To seed information (read information in from the YAML_FILENAME and save in the database):
  #       Seeders::SomeARModelSeeder.seed
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/15/19
  #
  #--------------------------
  #
  #
  class YamlSeeder

    # Subclasses should define this as needed using the class name. Ex: 'companies.yml' or 'addresses.yml'
    # This is a default so that data can be written
    YAML_FILENAME = 'shf-unknown-data.yml'

    YAML_PATH = File.join(__dir__, 'yaml-data')


    PROJECT_COMMENT = 'YAML Seed data for the SHF project'
    TOP_COMMENT_CLASS_INFO = 'YAML Data for class'
    TOP_COMMENT_DATE_INFO = 'Date written'
    COMMENT_SEPARATOR = '----------------------'

    YAML_FILE_STARTER = "---\n" # indicates this is a YAML file (format)

    OBJECTS_CREATED_END = 'objects seeded by'
    WARN_ZERO_OBJECTS_PREFIX = '!! WARNING: Zero objects were seeded by'
    WARN_ZERO_OBJECTS_END = '!!'


    # ================================================================


    # Seed objects: Read in a YAML file, create (persist) the objects,
    #  show info about how many objects were created,
    #  and return the list of objects created.
    #
    # @param [String] source_file_path - the full path of the YAML file to read
    # @return [Array<Object>] - list of all objects successfully created
    #
    def self.seed(source_file_path = full_yaml_filename)
      yaml_entries = read_yaml(source_file_path)
      objects_created = create_objects(yaml_entries)

      if objects_created.empty?
        tell_zero_objects_created_warning(self.name)
      else
        tell_num_objects_created(self.name, objects_created.size)
      end

      objects_created
    end


    # @return [Array<Hash> | Seeders::YamlSeederError] - the information read from the source file using YAML.load
    def self.read_yaml(source_file_path = full_yaml_filename)
      #YAML.load(File.read(source_file_path), symbolize_names: true)
      result = YAML.load(File.read(source_file_path), symbolize_names: true)
      if result.nil? || !result
        raise YamlSeederError, "No data loaded from the YAML file. 'YAML.load' returned nil. It could not read any data from the file.\n  YAML source file: #{source_file_path}"
      else
        result
      end
    end


    # Subclasses can override this as needed, especially if creating objects from the yaml is complex.
    #
    # @return [Array<Object>] - list of objects successfully created
    def self.create_objects(yaml_entries)
      created_objects = []
      yaml_entries.each { |yaml_entry| created_objects << create_object(yaml_entry) }
      created_objects
    end


    # SUBCLASSES MUST OVERRIDE THIS METHOD TO INSTANTIATE EACH OBJECT AND SAVE IT IN THE DB (OR WHEREVER IT SHOULD BE PERSISTED)
    #
    # @return [Object] - the object created
    #
    def self.create_object(_yaml_entry)
      raise NoMethodError, "Subclass must define the #{__method__} method", caller
    end


    # Write the serialized_objects to a YAML file.
    # Start with comments, then write the serialized objects.
    #
    # @return [String] - the full path and filename for the yaml file written to (the yaml output file)
    def self.write_yaml(basefn: yaml_filename, dir_path: yaml_path)
      yaml_out_fn = yaml_output_filename(basefn: basefn, dir_path: dir_path)
      write_to_yaml_source(YAML_FILE_STARTER, yaml_out_fn)
      write_to_yaml_source(top_comments, yaml_out_fn)

      serialized_str = serialized_objects.to_yaml

      # remove any leading "---\n" from the serialized string since we've already written that
      write_to_yaml_source(serialized_str.sub(/---(\s)*/, ''), yaml_out_fn)
      yaml_out_fn
    end


    # SUBCLASSES MUST OVERRIDE THIS METHOD TO CREATE THE SERIALIZED VERSION OF ALL OBJECTS IN YAML STRING FORM
    #
    # @return [String] - all of serialized objects in YAML form (object as a serialized YAML string)
    #
    def self.serialized_objects
      raise NoMethodError, "Subclass must define the #{__method__} method", caller
    end


    # Return the full path for the yaml output filename.
    # If the file already exists, create another filename with the timestamp appended
    #  and use put to write out a message that a different filename is being used
    #
    # @return [String] - full path filename
    #
    def self.yaml_output_filename(basefn: yaml_filename, dir_path: yaml_path)
      output_fn = File.join(dir_path, basefn)
      if File.exist?(output_fn)
        timestamped_out_fn = timestamped_fn(output_fn)
        tell_file_already_exists(output_fn, timestamped_out_fn)
        timestamped_out_fn
      else
        output_fn
      end
    end


    def self.top_comments
      standard_top_comments + additional_top_comments + comment_separator_line
    end


    # @return [String] - YAML comments about this class and when it was written out
    def self.standard_top_comments
      comment_line(PROJECT_COMMENT) +
          comment_line("#{TOP_COMMENT_CLASS_INFO}: #{self.name}") +
          comment_line("#{TOP_COMMENT_DATE_INFO}: #{Time.now}")
    end


    # Subclasses can override this to provide additional comments written at the top of the YAML file
    def self.additional_top_comments
      ''
    end


    def self.comment_separator_line
      comment_line(COMMENT_SEPARATOR)
    end


    def self.comment_line(text)
      "# #{text}\n"
    end


    # Append a timestamp to the name to try to ensure a unique filename (not absolutely guaranteed).
    # Keep the same file extension
    # @return [String] - a filename with the timestamp
    def self.timestamped_fn(orig_fn)
      file_ext = File.extname(orig_fn)
      base_fn = File.basename(orig_fn, '.*')
      fulldir = File.dirname(orig_fn)
      File.join(fulldir, "#{base_fn}-#{Time.now.strftime("%F-%H%M%S%z")}#{file_ext}")
    end


    # =============================
    # =============================


    # Create an OrderedListEntry from the yaml_hash, then each entry in [:children] (this recurses top-down)
    #
    def self.create_entry_and_children(yaml_hash, parent_ordered_entry: nil)

      new_ordered_entry = create_ordered_entry(yaml_hash, parent_ordered_entry: parent_ordered_entry)

      yaml_hash.fetch(:children, []).each do |yaml_child_entry|
        create_entry_and_children(yaml_child_entry, parent_ordered_entry: new_ordered_entry)
      end
    end


    def self.create_ordered_entry(yaml_entry, parent_ordered_entry: nil)
      OrderedListEntry.create!(name: yaml_entry[:name],
                               description: yaml_entry[:description],
                               list_position: yaml_entry[:list_position] ? yaml_entry[:list_position] : 0,
                               parent: parent_ordered_entry)
    end


    # Append output_str to the file.  Close the file after writing
    #
    # @param [String] output_str - the string to write to the file
    # @param [Path | String] output_filename - the path of the file to write out to
    def self.write_to_yaml_source(output_str = '', output_filename = YAML_FILENAME)
      File.open(output_filename, "a") { |file| file.write(output_str) }
    end


    def self.tell_file_already_exists(existing_fn, filename_used_instead)
      tell(" WARNING: #{self.name} .write_yaml : #{existing_fn} already exists.  Writing out to #{filename_used_instead}")
    end


    def self.tell_num_objects_created(name, num)
      tell("#{num} #{OBJECTS_CREATED_END} #{name}.")
    end


    def self.tell_zero_objects_created_warning(name)
      tell("#{WARN_ZERO_OBJECTS_PREFIX} #{name} #{WARN_ZERO_OBJECTS_END}")
    end


    # Having this method makes it easy to silence any puts output (e.g. for testing)
    def self.tell(str)
      puts(str)
    end


    # -----------------------
    # In addition to being good OO encasulation,
    # these methods ensure that we are using the constants of the subclass (or included/extended classes/modules)


    def self.yaml_filename
      self::YAML_FILENAME
    end


    def self.yaml_path
      self::YAML_PATH
    end


    def self.full_yaml_filename
      File.join(yaml_path, yaml_filename)
    end

  end

end
