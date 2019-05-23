#--------------------------
# Context for running RSpec for a Rails/Rake task
#
# @author Josh Clayton
#  with modifications by Ashley Engelund (modifications to the task_path)
#
# @date  October 6, 2015
#
# @desc Sets up a context so rails/rake tasks can be tested.  From the
# blog post about this:
# https://thoughtbot.com/blog/test-rake-tasks-like-a-boss
#  - with modifications about "describe" and the task_path and task_name
#    by Ashley Engelund
#
# The top level "RSpec.describe()" is used to get the rake file location
# (the task_path) _and_ the rake task to test.
#
# The general pattern must be "<rake file>[space]<task name>".
# The rake file is _assumed_ to be under <Rails.root>/lib/tasks
# If it in a subdirectory of lib/tasks, that must be part of the rake file name.
#
# Examples:
#
# describe("reports user") { }
#  # rake file is lib/tasks/reports.rake
#  # subject is Rake::Task["user"]
#
# The top level :describe should provide the rake file name that is being tested,
#   followed by a space,
#  followed by the task name (including any namespacing).
#
# The rake file name should be relative to Rails.root.join('lib','tasks')
# In other words, if the file is in <Rails.root>/lib/tasks then just provide the filename.
# (No ".rake" extension)
# If the file is in a subdirectory _under_ <Rails.root>/lib/tasks then also include
# the path.
#
# Ex:
#   If the rake file being tested is
#     <Rails.root>/lib/tasks/validate/quarterly.rake
#   and the task being tested is "reports:user"
#   then the description should be
#     describe('validate/quarterly reports:user')
#
# _This will not currently handle any rake files that are not under Rails.root/lib/tasks._
#
# :loaded_files_excluding_current_rake_file - this requires a bit
# of explanation, even with that really descriptive method name.
# Rake is kind of a pain in certain cases; The rake_require method
# takes three arguments: the path to the task, an array of directories
# to look for that path, and a list of all the files previously loaded.
#
# rake_require takes loaded paths into account, so we exclude the path
# to the task we’re testing so we have the task available.
# This only matters when you’re running more than one test on a rake task,
# but there’s no harm in doing this every time we test so that there aren’t
# odd edge cases out there.
#
# Finally, I define the :environment task (which most tasks defined in a Rails
# app will have as a prerequisite, since it’ll load the Rails stack for
# accessing models and code within lib without any additional work.
#
# @file spec/support/shared_contexts/rake.rb
#
#
# Example usage:
#
# --------------------------------------
# # spec/lib/tasks/reports_rake_spec.rb
#
# describe "reports users" do
#
#   include_context "rake"
#
#   let(:csv)          { stub("csv data") }
#   let(:report)       { stub("generated report", :to_csv => csv) }
#   let(:user_records) { stub("user records for report") }
#
#   before do
#     ReportGenerator.stubs(:generate)
#     UsersReport.stubs(:new => report)
#     User.stubs(:all => user_records)
#   end
#
#   its(:prerequisites) { should include("environment") }
#
#   it "generates a registrations report" do
#     subject.invoke
#     ReportGenerator.should have_received(:generate).with("users", csv)
#   end
#
#   it "creates the users report with the correct data" do
#     subject.invoke
#     UsersReport.should have_received(:new).with(user_records)
#   end
# end
#
#
#  # the rake file is lib/tasks/validate/reports.rake
#  # and the task is :purchases
# describe "validate/reports.rake purchases" do
#
#   include_context "rake"
#
#   let(:csv)              { stub("csv data") }
#   let(:report)           { stub("generated report", :to_csv => csv) }
#   let(:purchase_records) { stub("purchase records for report") }
#
#   before do
#     ReportGenerator.stubs(:generate)
#     PurchasesReport.stubs(:new => report)
#     Purchase.stubs(:valid => purchase_records)
#   end
#
#   its(:prerequisites) { should include("environment") }
#
#   it "generates an purchases report" do
#     subject.invoke
#     ReportGenerator.should have_received(:generate).with("purchases", csv)
#   end
#
#   it "creates the purchase report with the correct data" do
#     subject.invoke
#     PurchasesReport.should have_received(:new).with(purchase_records)
#   end
# end
#
#  # the rake file is lib/tasksreports.rake
#  # and the task is :all
# describe "reports all" do
#
#  include_context "rake"
#
#   its(:prerequisites) { should include("users") }
#   its(:prerequisites) { should include("purchases") }
# end
#
#
#--------------------------

require "rake"

RSpec.shared_context "rake" do

  let(:rake)      { Rake::Application.new }

  let(:described_parts) { self.class.top_level_description .split(' ') }
  let(:task_path) { File.join('lib', 'tasks', described_parts.first) }
  let(:task_name) { described_parts.last.strip }

  subject         { rake[task_name] }

  # This is the same as Rails.root, but we cannot assume Rails is loaded
  ROOT_DIR = File.join(__dir__, '..', '..') unless defined?(ROOT_DIR)

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == File.join(ROOT_DIR,"#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [ROOT_DIR.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end
end
