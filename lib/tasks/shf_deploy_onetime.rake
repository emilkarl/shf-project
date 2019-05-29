# Tasks to run to deploy the application.  Tasks defined here can be called by capistrano.

require 'active_support/logger'
require_relative 'one_time_tasks_finder'


namespace :shf do

  namespace :deploy do

    SHFDEPLOY_LOG_FACILITY = 'SHF_DEPLOY_TASK' unless defined?(SHFDEPLOY_LOG_FACILITY)


    desc 'run any one_time tasks not yet run, for this quarter in this year'
    task run_onetime_tasks: [:environment] do |task_name|

      logfile_name = LogfileNamer.name_for(OneTimeTasksFinder::SHFDEPLOY_LOG_NAME)
      log          = ActivityLogger.open(logfile_name,
                                         SHFDEPLOY_LOG_FACILITY,
                                         task_name)

      tasks_finder         = OneTimeTasksFinder.instance

      # this is where the tasks_finder will look for tasks that have already been run
      tasks_finder.logfile = logfile_name

      load_onetime_rakefiles(tasks_finder)
      onetime_task_names = tasks_finder.names_of_tasks_to_run_today
      invoke_onetime_tasks(onetime_task_names, tasks_finder, log)

      log.close
    end


    def load_onetime_rakefiles(tasks_finder)
      # load the rakefiles that we should run now
      onetime_rakefiles    = tasks_finder.onetime_rake_files
      onetime_rakefile_dir = tasks_finder.onetime_tasks_path
      onetime_rakefiles.each { |rakefile| Rake.load_rakefile(File.join(onetime_rakefile_dir, rakefile)) }
    end


    def invoke_onetime_tasks(task_names, tasks_finder, log)

      task_names.each do |task_name|
        begin
          Rake.application[task_name].reenable
          Rake.application[task_name].invoke
          log.record('info', tasks_finder.task_log_entry_str(task_name) + " #{Time.zone.now}")

        rescue StandardError => error
          log.record('error', "Task #{task_name} did not run successfully: #{error}")
        end
      end

    end

  end
end
