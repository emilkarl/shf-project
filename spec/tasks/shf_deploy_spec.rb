require 'rails_helper'
require 'shared_context/rake'
require 'shared_context/activity_logger'
require 'shared_context/simple_rake_task_maker'


RSpec.describe 'shf_deploy shf:deploy:run_onetime_tasks', type: :task do

  include_context 'rake'
  include_context 'create logger'
  include_context 'simple rake task maker'

  let(:logfilepath) { LogfileNamer.name_for(OneTimeTasksFinder::SHFDEPLOY_LOG_NAME) }

  let(:may_1_2019) { Time.parse('2019-05-01') }
  let(:this_date_str) { may_1_2019.strftime("%Y-%m-%d") }

  before(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)
  end

  after(:each) do
    File.delete(logfilepath) if File.file?(logfilepath)
  end


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
          expect(file_contents).to include("One-time task shf:test:task0 was run on #{this_date_str}")
          expect(file_contents).to include("One-time task shf:test:task1 was run on #{this_date_str}")
          expect(file_contents).to include("One-time task shf:test:task2 was run on #{this_date_str}")
        end
      end


      context 'an error happened' do

        it 'logs the error, but not as entry that signifies that the task ran successfully (so it can be run again later).' do
          temp_onetime_path = Dir.mktmpdir('test-run_onetime_tasks')
          allow_any_instance_of(OneTimeTasksFinder).to receive(:onetime_tasks_path).and_return(temp_onetime_path)

          # Create 1 .rake files in the 2019_Q2 directory
          make_simple_rakefiles_under_subdir(temp_onetime_path, '2019_Q2', 1)

          # Create 1 rake file that will cause an error:
          taskname = "bad_task"
          bad_task = "namespace :shf do\n" +
              "  namespace :test do\n" +
              "    desc 'bad task'\n" +
              "    task #{taskname}: :environment do\n" +
              "       puts \"  Task #{__FILE__} #{taskname} has been invoked.\"\n " +
              "       raise NoMethodError\n" +
              "    end\n" +
              "  end\n" +
              "end\n"
          badtask_fn = File.join(temp_onetime_path, '2019_Q2', 'bad_task.rake')
          File.open(badtask_fn, 'w') do |f|
            f.puts bad_task
          end

          # This should keep running and not raise an error just because 1 task fails; it should log the error(s)
          Timecop.freeze(may_1_2019) do
            expect { subject.invoke }.not_to raise_error
          end

          file_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
          expect(file_contents).to include("[error] Task shf:test:bad_task did not run successfully: NoMethodError")
          expect(file_contents).to include("One-time task shf:test:task0 was run on #{this_date_str}")
        end
      end
    end
  end


  context 'no tasks found' do

    it 'nothing invoked' do

      Timecop.freeze(may_1_2019) do
        expect { subject.invoke }.not_to raise_error
      end

      after_logfile_contents = File.exist?(logfilepath) ? File.read(logfilepath) : 'logfilepath does not exist'
      expect(after_logfile_contents).not_to include("One-time task")
      expect(after_logfile_contents).not_to include("did not run successfully")
    end
  end

end
