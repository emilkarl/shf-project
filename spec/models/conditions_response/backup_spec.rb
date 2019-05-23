require 'rails_helper'
require 'email_spec/rspec'

require 'shared_examples/shared_condition_specs'
require 'shared_context/activity_logger'


RSpec.describe Backup, type: :model do

  include_context 'create logger'


  let(:condition) { build(:condition, timing: Backup::TIMING_EVERY_DAY) }
  let(:today) { Time.now.strftime '%Y-%m-%d' }


  let(:today_timestamp) { Backup.today_timestamp }
  let(:expected_bucket) { ENV['SHF_AWS_S3_BACKUP_BUCKET'] }
  let(:expected_bucket_folder) { "production_backup/#{today_timestamp}/" }

  def create_faux_backup_file(backups_dir, file_prefix)
    File.open(File.join(backups_dir, "#{file_prefix}-faux-backup.bak"), 'w').path
  end



  describe '#backup_dir' do

    it 'uses the backup_directory in the config' do
      backup = build(:condition, :every_day, config: { backup_directory: 'blorf-dir' } )
      expect(described_class.backup_dir(backup.config)).to eq 'blorf-dir'
    end

    it 'if the dir in the config is not found, uses /home/deploy/SHF_BACKUPS/' do
      backup = build(:condition, :every_day )
      expect(described_class.backup_dir(backup.config)).to eq '/home/deploy/SHF_BACKUPS/'
    end

  end


  describe '#backup_target_fn' do

    it 'puts the file into the backup directory, appends a timestamp and .gz to the base filename' do
      timestamp = Time.now.strftime Backup::TIMESTAMP_FMT
      expect(described_class.backup_target_fn('blorf-dir', 'blorf')).to eq(File.join( 'blorf-dir', "blorf#{timestamp}.gz"))
    end
  end


  describe 'get_s3_objects' do

    it 'requires ENV variables for the AWS credentials and region' do
      expect(ENV.fetch('SHF_AWS_S3_BACKUP_BUCKET', nil)).not_to be_nil
      expect(ENV.fetch('SHF_AWS_S3_BACKUP_REGION', nil)).not_to be_nil
      expect(ENV.fetch('SHF_AWS_S3_BACKUP_KEY_ID', nil)).not_to be_nil
      expect(ENV.fetch('SHF_AWS_S3_BACKUP_SECRET_ACCESS_KEY', nil)).not_to be_nil
    end

    it 'uses the argument as part of the bucket folder name' do
      result = Backup.get_s3_objects('blorfo')
      expect(result[2]).to eq "production_backup/blorfo/"
    end

    it 'uses Bucket.today_timestamp is no argument is given' do
      result = Backup.get_s3_objects
      expect(result[1]).to eq expected_bucket
      expect(result[2]).to eq expected_bucket_folder
    end

    it 'returns array of [AWS S3 credentials, bucket, bucket_folder' do
      result = Backup.get_s3_objects(today_timestamp)
      expect(result[1]).to eq expected_bucket
      expect(result[2]).to eq expected_bucket_folder
    end

  end


  it 'upload_file_to_s3 calls .upload_file for the bucket, folder, and file to upload' do

    temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
    faux_backup_fn = create_faux_backup_file( temp_backups_dir, 'faux_backup.bak')

    expect_any_instance_of( Aws::S3::Object).to receive(:upload_file).with(faux_backup_fn).and_return(true)

    aws_s3_resource, bucket, bucket_folder = Backup.get_s3_objects(today_timestamp)

    Backup.upload_file_to_s3(aws_s3_resource, bucket, bucket_folder, faux_backup_fn)

    FileUtils.remove_entry(temp_backups_dir, true)
  end


  it 'delete_excess_backup_files sorts based on filename, deleting those that come first' do

      # create some faux backup files
      temp_backups_dir = Dir.mktmpdir('faux-backups-dir')
      backup_a0 = create_faux_backup_file(temp_backups_dir, 'a0')
      backup_a1 = create_faux_backup_file(temp_backups_dir, 'a1')
      backup_a2 = create_faux_backup_file(temp_backups_dir, 'a2')
      backup_a3 = create_faux_backup_file(temp_backups_dir, 'a3')

      expect(File.exist?(backup_a0)).to be_truthy
      expect(File.exist?(backup_a1)).to be_truthy
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      Backup.delete_excess_backup_files("#{temp_backups_dir}/*.bak", 2)

      expect(File.exist?(backup_a0)).to be_falsey
      expect(File.exist?(backup_a1)).to be_falsey
      expect(File.exist?(backup_a2)).to be_truthy
      expect(File.exist?(backup_a3)).to be_truthy

      FileUtils.remove_entry(temp_backups_dir, true)
  end


  describe '.condition_response' do

    class FakeLogger
      def self.record(*args)
      end
    end

    # stub out these methods
    before(:each) do
      allow_any_instance_of(AbstractBackupMaker).to receive(:shell_cmd)

      allow(described_class).to receive(:get_s3_objects)
      allow(described_class).to receive(:upload_file_to_s3)
      allow(described_class).to receive(:delete_excess_backup_files)
    end


    it_behaves_like 'it validates timings in .condition_response', [:every_day] do
      let(:tested_condition) { condition }
    end


    it 'calls S3 credentials once' do
      expect(described_class).to receive(:get_s3_objects)
        .with(today).exactly(1).times

      described_class.condition_response(condition, FakeLogger)
    end

    it 'calls upload to S3 once for each Backup maker ' do
      # if no files are in the config, there are only 2 backup makers
      expect(described_class).to receive(:upload_file_to_s3).exactly(2).times

      described_class.condition_response(condition, FakeLogger)
    end


    describe '.create_backup_targets' do

      describe 'adds a CodeBackupMaker and a DBBackupMaker' do

        it 'CodeBackupMaker number to keep is from config if days_to_keep: {code_backup: N} exists' do
          targets = described_class.create_backup_targets({days_to_keep: {code_backup: 12} })
          code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker}.first
          expect(code_backupmaker[:keep_num]).to eq 12
        end

        it 'CodeBackupMaker number to keep is 4 (default) if not in config' do
          targets = described_class.create_backup_targets({})
          code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].is_a? CodeBackupMaker}.first
          expect(code_backupmaker[:keep_num]).to eq 4
        end

        it 'DBBackupMaker number to keep is from config if days_to_keep: {db_backup: N} exists' do
          targets = described_class.create_backup_targets({days_to_keep: {db_backup: 12} })
          code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker}.first
          expect(code_backupmaker[:keep_num]).to eq 12
        end

        it 'DBBackupMaker number to keep is 15 (default) if not in config' do
          targets = described_class.create_backup_targets({})
          code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].is_a? DBBackupMaker}.first
          expect(code_backupmaker[:keep_num]).to eq 15
        end

      end


      describe 'only adds a FileBackupMaker if needed' do

        it 'no FileBackupMaker created after reading the config' do
          allow(described_class).to receive(:create_files_backup_maker).and_return(nil)

          targets = described_class.create_backup_targets({files: ['thisfile'], days_to_keep: {files_backup: 12} })
          files_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].class.name ==  'FilesBackupMaker'}

          expect(files_backupmaker).to be_empty
        end

        it 'a FileBackupMaker is created after reading the config' do

          allow(described_class).to receive(:create_files_backup_maker).and_return(FilesBackupMaker.new)

          targets = described_class.create_backup_targets({files: ['thisfile'], days_to_keep: {files_backup: 12} })
          files_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].class.name ==  'FilesBackupMaker'}

          expect(files_backupmaker).not_to be_empty
        end

      end

      it 'FilesBackupMaker number to keep is from config if days_to_keep: {files_backup: N} exists' do
        targets = described_class.create_backup_targets({files: ['thisfile'], days_to_keep: {files_backup: 12} })
        code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].class.name ==  'FilesBackupMaker'}.first
        expect(code_backupmaker[:keep_num]).to eq 12
      end

      it 'FilesBackupMaker number to keep is 31 (default) if not in config' do
        targets = described_class.create_backup_targets({files: ['thisfile']})
        code_backupmaker = targets.select{|maker_entry| maker_entry[:backup_maker].class.name == 'FilesBackupMaker'}.first
        expect(code_backupmaker[:keep_num]).to eq 31
      end

    end


    describe '.create_files_backup_maker' do

      it 'nil if there is no files: entry in config' do
        expect(described_class.create_files_backup_maker({})).to be_nil
      end

      it 'raises ShfConditionError::BackupConfigFilesBadFormatError if not an array' do
        expect{described_class.create_files_backup_maker({files: 'blorf'})}.to raise_exception(ShfConditionError::BackupConfigFilesBadFormatError)
      end

      it 'nil if the list is empty: []' do
        expect(described_class.create_files_backup_maker({files: []})).to be_nil
      end

      it 'creates a FileBackupMaker with the list as the source files for the backup' do
        created_maker = described_class.create_files_backup_maker({files: ['~/NOTES_RUNNING_LOG.txt', '/var/log/nginx']})
        expect(created_maker.backup_sources).to match_array(['~/NOTES_RUNNING_LOG.txt', '/var/log/nginx'])
      end

    end

  end


  describe 'BackupMaker classes' do


    describe 'AbstractBackupMaker' do

      let(:abstract_backup_using_defaults) { AbstractBackupMaker.new }

      it 'default sources = []' do
        expect(abstract_backup_using_defaults.backup_sources).to eq []
      end

      it 'default backup target base filename = backup-<class name>.tar' do
        expect(abstract_backup_using_defaults.backup_target_filebase).to eq 'backup-AbstractBackupMaker.tar.'
      end

      it 'shell_cmd calls %x with the string passed in' do
        # have to test with a subclass that implements :backup
        test_file_backupmaker = FilesBackupMaker.new

        expect(test_file_backupmaker).to receive(:shell_cmd).with('tar -chzf backup-FilesBackupMaker.tar. ')

        test_file_backupmaker.backup
      end

      it 'backup raises NoMethodError Subclasses must define' do
        expect{abstract_backup_using_defaults.backup}.to raise_error(NoMethodError, 'Subclass must define the backup method')
      end

    end


    describe 'FilesBackupMaker' do

      let(:backup_using_defaults) { FilesBackupMaker.new }

      it 'default backup target base filename = backup-FilesBackupMaker.tar' do
        expect(backup_using_defaults.backup_target_filebase).to eq 'backup-FilesBackupMaker.tar.'
      end


      it '#backup creates a tar with all entries in sources using tar -chzf}' do

        temp_backup_target = Tempfile.new('code-backup.').path
        temp_backup_sourcefn1 = Tempfile.new('faux-codefile.rb').path
        temp_backup_sourcefn2 = Tempfile.new('faux-otherfile.rb').path

        temp_backup_sourcedir = Dir.mktmpdir('faux-code-dir')
        temp_backup_in_dir_fn = File.open(File.join(temp_backup_sourcedir, 'faux-codefile2.rb'), 'w').path

        files_backup = FilesBackupMaker.new(backup_target_filebase: temp_backup_target,
                                         backup_sources: [temp_backup_sourcefn1,
                                                          temp_backup_sourcefn2,
                                                          temp_backup_sourcedir])
        files_backup.backup

        # could also use the Gem::Package verify_entry method to verify each tar entry
        backup_file_list = %x<tar --list --file=#{temp_backup_target}>
        backup_file_list.gsub!(/\n/, ' ')

        # tar will remove leading "/" from source file names, so remove the leading "/"
        expected = "#{temp_backup_sourcefn1.gsub(/^\//, '')} " +
            "#{temp_backup_sourcefn2.gsub(/^\//, '')} " +
            "#{temp_backup_sourcedir.gsub(/^\//, '')}/ " +
            "#{temp_backup_in_dir_fn.gsub(/^\//, '')}"

        expect(backup_file_list.strip).to eq expected

        FileUtils.remove_entry temp_backup_sourcedir
      end

    end


    describe 'CodeBackupMaker' do

      let(:backup_using_defaults) { CodeBackupMaker.new }

      it 'default backup target base filename = current.tar.' do
        expect(backup_using_defaults.backup_target_filebase).to eq 'current.tar.'
      end

      it 'default sources = [CODE_ROOT_DIRECTORY]' do
        expect(backup_using_defaults.backup_sources).to eq ['/var/www/shf/current/']
      end

    end


    describe 'DBBackupMaker' do

      let(:backup_using_defaults) { DBBackupMaker.new }

      it 'default backup target base filename = db_backup.sql.' do
        expect(backup_using_defaults.backup_target_filebase).to eq 'db_backup.sql.'
      end

      it 'default sources = [DB_NAME]' do
        expect(backup_using_defaults.backup_sources).to eq ['shf_project_production']
      end


      it '#backup dumps the dbs in sources and creates 1 backup gzipped file', focus: true do

        temp_backup_target = Tempfile.new('code-backup.').path

        new_db_backup = DBBackupMaker.new(backup_target_filebase: temp_backup_target, backup_sources: ['this1', 'that2'])

        expect(new_db_backup).to receive(:shell_cmd).with("touch #{temp_backup_target}")
        expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d this1 | gzip > #{temp_backup_target}")
        expect(new_db_backup).to receive(:shell_cmd).with("pg_dump -d that2 | gzip > #{temp_backup_target}")

        new_db_backup.backup

      end

    end

  end

end
