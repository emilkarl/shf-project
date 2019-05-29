require 'rails_helper'
require 'shared_context/rake'
require 'shared_context/activity_logger'
require 'shared_context/simple_rake_task_maker'


RSpec.describe 'shf_deploy_onetime shf:deploy:run_onetime_tasks', type: :task do

  include_context 'rake'
  include_context 'create logger'
  include_context 'simple rake task maker'

  let(:logfilepath) { LogfileNamer.name_for(OneTimeTasksFinder::SHFDEPLOY_LOG_NAME) }
  let(:simple_test_tasks_logfile) { LogfileNamer.name_for(SIMPLE_RAKE_TASK_LOGFILE) }

  before(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)
    File.delete(simple_test_tasks_logfile) if File.file?(simple_test_tasks_logfile)
  end

  after(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)
    File.delete(simple_test_tasks_logfile) if File.file?(simple_test_tasks_logfile)
  end


  let(:may_1_2019) { Time.parse('2019-05-01') }
  let(:may_29_2019) { Time.parse('2019-05-29') }
  let(:may_1_str) { may_1_2019.strftime("%Y-%m-%d") }
  let(:may_29_str) { may_29_2019.strftime("%Y-%m-%d") }


  context 'tasks found' do

    describe 'invokes each task' do

      context 'all ran successfully' do

        it 'invokes each task and logs that each task ran' do
          temp_onetime_path = Dir.mktmpdir('test-run_onetime_tasks')
          allow_any_instance_of(OneTimeTasksFinder).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

          # Create 3 .rake files in the 2019_Q2 directory
          make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 3)

          Timecop.freeze(may_1_2019) do
            expect { subject.invoke }.not_to raise_error
          end

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).not_to include('ERROR')
          expect(file_contents).to include("One-time task shf:test:task0 was run on #{may_1_str}")
          expect(file_contents).to include("One-time task shf:test:task1 was run on #{may_1_str}")
          expect(file_contents).to include("One-time task shf:test:task2 was run on #{may_1_str}")
        end
      end


      context 'an error happened' do

        it 'logs the error, but not as entry that signifies that the task ran successfully (so it can be run again later).' do
          temp_onetime_path = Dir.mktmpdir('test-run_onetime_tasks')
          allow_any_instance_of(OneTimeTasksFinder).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

          # Create 1 .rake file in the 2019_Q2 directory
          make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 1)

          # Create 1 rake file that will raise an error unless it is run on 29 May 2019 (use Timecop!)
          make_simple_rakefile_under_subdir(temp_onetime_path, '2019_Q2', 'bad_task', "raise NoMethodError unless DateTime.current.to_date == Date.new(2019, 5, 29)\n")

          # This should keep running and not raise an error just because 1 task fails; it should log the error(s)
          Timecop.freeze(may_1_2019) do
            expect { subject.invoke }.not_to raise_error
          end

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).to include("[error] Task shf:test:bad_task did not run successfully: NoMethodError")
          expect(file_contents).to include("One-time task shf:test:task0 was run on #{may_1_str}")
        end


        it 'a task will be invoked next time if an error happened before' do

          temp_onetime_path = Dir.mktmpdir('test-run_onetime_tasks')
          allow_any_instance_of(OneTimeTasksFinder).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

          # Create 1 .rake file in the 2019_Q2 directory
          make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 1)

          # Create 1 rake file that will raise an error unless it is run on 29 May 2019 (use Timecop!)
          make_simple_rakefile_under_subdir(temp_onetime_path, '2019_Q2', 'bad_task', "raise NoMethodError unless DateTime.current.to_date == Date.new(2019, 5, 29)\n")

          # the 'bad_task will fail'
          Timecop.freeze(may_1_2019) do
            expect { subject.invoke }.not_to raise_error
          end

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).to include("[error] Task shf:test:bad_task did not run successfully: NoMethodError")
          expect(file_contents).to include("One-time task shf:test:task0 was run on #{may_1_str}")


          # The 'bad_task' should be invoked again and succeed
          Timecop.freeze(may_29_2019) do
            expect do
              subject.reenable
              subject.invoke
            end.not_to raise_error
          end

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).to include("One-time task shf:test:bad_task was run on #{may_29_str}")
        end
      end

    end
  end


  context 'no tasks found' do

    it 'nothing invoked' do

      allow(OneTimeTasksFinder.instance).to receive(:names_of_tasks_to_run_today).and_return([])
      Timecop.freeze(may_1_2019) do
        expect { subject.invoke }.not_to raise_error
      end

      after_logfile_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
      expect(after_logfile_contents).not_to include("One-time task")
      expect(after_logfile_contents).not_to include("did not run successfully")
    end
  end

end
