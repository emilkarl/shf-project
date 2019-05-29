require 'rails_helper'
require_relative File.join(__dir__, '..', '..', '..', 'lib', 'tasks', 'one_time_tasks_finder')
require 'rake'

require 'shared_context/activity_logger'
require 'shared_context/simple_rake_task_maker'


RSpec.describe OneTimeTasksFinder, type: :model do

  include_context 'create logger'
  include_context 'simple rake task maker'

  let(:subject) { described_class.instance }

  let(:task_name) { 'some task' }

  let(:may_1_2019) { Time.parse('2019-05-01')}


  describe 'names_of_tasks_to_run_today' do


    it 'only those tasks that have not yet been run' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)


      # Create 4 .rake files and in the 2019_Q2 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 4)

      subject.logfile = logfilepath # logfile name in the shared_context/activity_logger

      # Create a log file that has entries for task0 and task2 (already run)
      log.info("One-time task shf:test:task0 was run on ..whatever...")
      log.info("One-time task shf:test:task2 was run on ..whatever...")

      Timecop.freeze(may_1_2019) do
        expect(subject.names_of_tasks_to_run_today).to match_array(['shf:test:task1', 'shf:test:task3'])
      end
    end


    it 'empty list if all tasks have been run' do

      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 3 .rake files in the 2019_Q2 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 3)

      subject.logfile = logfilepath # logfile name in the shared_context/activity_logger

      # Create a log file that has entries for task0 and task1 and task2 (already run)
      log.info("One-time task shf:test:task0 was run on ..whatever...")
      log.info("One-time task shf:test:task1 was run on ..whatever...")
      log.info("One-time task shf:test:task2 was run on ..whatever...")

      Timecop.freeze(may_1_2019) do
        expect(subject.names_of_tasks_to_run_today).to be_empty
      end
    end


    it 'empty list if no rake files are in directories matching the criteria' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 3 .rake files in the 2019_Q3 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q3', 3)

      Timecop.freeze(may_1_2019) do
        expect(subject.names_of_tasks_to_run_today).to be_empty
      end
    end

  end


  describe 'onetime_rake_files' do

    it 'empty if the onetime path does not exist' do
      allow(subject).to receive(:onetime_tasks_path).and_return('blorf')

      expect(subject.onetime_rake_files).to be_empty
    end

    it 'empty if no .rake files' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      expect(subject.onetime_rake_files).to be_empty
    end


    it 'only includes .rake files in directories that meet the criteria (yyyy quarter pattern)' do
      temp_onetime_path = Dir.mktmpdir('test-onetime_rake_files')
      allow(subject).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

      # Create 3 .rake files in the 2019_Q2 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 3)

      # Create 3 .rake files in the 2019_Q3 directory
      make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q3', 3)

      Timecop.freeze(may_1_2019) do
        expect(subject.onetime_rake_files).to match_array(["2019_Q2/test0.rake", "2019_Q2/test1.rake", "2019_Q2/test2.rake"])
      end

    end

  end


  describe 'directory_name_meets_criteria?' do

    describe 'directory must exactly match YYYY_[Q|q]<quarter number> where quater number is an integer 1-4' do

      before(:each) { Timecop.freeze(may_1_2019) }
      after(:each) { Timecop.return }

      it 'true: right format, right year, right quarter' do
        expect(subject.directory_name_meets_criteria?('2019_q2/blorf.rake')).to be_truthy
        expect(subject.directory_name_meets_criteria?('2019_Q2/blorf.rake')).to be_truthy
      end

      it 'true: can start with a slash or not' do
        expect(subject.directory_name_meets_criteria?('/2019_q2/blorf.rake')).to be_truthy
        expect(subject.directory_name_meets_criteria?('/2019_Q2/blorf.rake')).to be_truthy
        expect(subject.directory_name_meets_criteria?('2019_q2/blorf.rake')).to be_truthy
        expect(subject.directory_name_meets_criteria?('2019_Q2/blorf.rake')).to be_truthy
      end
      
      it 'true: rake file can be nested under sub directories' do
        expect(subject.directory_name_meets_criteria?('2019_q2/subdir/subdir/blorf.rake')).to be_truthy
        expect(subject.directory_name_meets_criteria?('/2019_Q2/subdir/blorf.rake')).to be_truthy
      end
      
      it 'false: right format, not this year' do
        expect(subject.directory_name_meets_criteria?('/2020_q1/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_Q1/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_q2/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_Q2/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_Q3/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_q3/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_Q4/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2020_q4/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2018_q2/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2018_Q2/blorf.rake')).to be_falsey
      end

      it 'false: right format, right year, not this quarter' do
        expect(subject.directory_name_meets_criteria?('/2019_q1/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_Q1/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_Q3/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_q3/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_Q4/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_q4/blorf.rake')).to be_falsey
      end

      it 'false: not the right format, right year, right quarter' do
        expect(subject.directory_name_meets_criteria?('/z2019_q2/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_Q2z/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_2/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_2q/blorf.rake')).to be_falsey
        expect(subject.directory_name_meets_criteria?('/2019_2Q/blorf.rake')).to be_falsey
      end
    end
  end


  describe 'has_task_been_run?(task_name)' do

    it 'true if there is an entry in the logfile' do
      allow(subject).to receive(:task_in_log_file?).and_return(true)
      expect(subject.has_task_been_run?(task_name)).to be_truthy
    end

    it 'false if no entry in the logfile' do
      allow(subject).to receive(:task_in_log_file?).and_return(false)
      expect(subject.has_task_been_run?(task_name)).to be_falsey
    end
  end


  describe 'task_in_log_file?(task_name, logfile_path)' do

    before(:each) do
      4.times { |i| log.info("some entry #{i}") }
    end


    it 'true if an entry for the task_name is in the log file' do
      log.info("One-time task #{task_name} was run on ..whatever...")
      expect(subject.task_in_log_file?(task_name, logfilepath)).to be_truthy
    end

    it 'false if there is no entry for the task_name in the log file' do
      expect(subject.task_in_log_file?(task_name, logfilepath)).to be_falsey
    end

    it 'false if logfile does not exist' do
      expect(subject.task_in_log_file?(task_name, File.join(__dir__, 'does-not-exist'))).to be_falsey
    end
  end


  describe 'task_log_entry_str' do
    it "is One-time task <task_name> was run on" do
      expect(subject.task_log_entry_str('some task name')).to eq 'One-time task some task name was run on'
    end
  end

end
