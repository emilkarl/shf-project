RSpec.shared_context 'simple rake task maker' do


    # Create a subdirectory <subdir> under <directory if it doesn't already exist,
  # and then create <num> simple rake files in <subdir>
  def make_simple_rakefiles_under_subdir(directory, subdir, num = 1, start_num: 0)
    new_sub_dir = File.join(directory, subdir)
    Dir.mkdir(new_sub_dir) unless Dir.exist?(new_sub_dir)

    make_simple_rakefiles(new_sub_dir, num, start_num: start_num)
  end


  # Make <num> .rake files in the directory; each rake file contains 1 simple task
  # start_num = the first task number
  def make_simple_rakefiles(directory, num = 1, start_num: 0)
    num.times do |i|
      task_num = i + start_num
      File.open(File.join(directory, "test#{task_num}.rake"), 'w') do |f|
        f.puts simple_rake_task(task_num)
      end
    end
  end


  # String for a simple task that just prints out (puts) that it was invoked when it is invoked.
  def simple_rake_task(task_num)
    taskname = "task#{task_num}"
    "namespace :shf do" +
    "  namespace :test do" +
    "    desc 'task number #{task_num}'\n" +
    "    task #{taskname}: :environment do\n" +
    "       puts \"  Task #{__FILE__} #{taskname} has been invoked.\"\n " +
    "    end\n" +
    "  end\n" +
    "end\n"
  end


end
