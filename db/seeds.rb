# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).

require 'ffaker'
require 'rake'

require_relative './seed_helpers'

# require all *.rb files in these subdirectories
required_subdirs = %w(seed_helpers seeders)
required_subdirs.each do | required_subdir |
  Dir[File.join(__dir__, required_subdir, '**','*.rb')].each do |file|
    require file
  end
end


include SeedHelper

# The test of defined? is due to the rspec file that executes the seed file
# repeatedly.  Without this, rspec complains about "already initialized constant"
SEED_STOP_MSG = '<<< SEEDING STOPPED' unless defined?(SEED_STOP_MSG)

SEED_COMPLETE_MSG = '<<< SEEDING COMPLETED' unless defined?(SEED_COMPLETE_MSG)

SEED_USERS = 100 unless defined?(SEED_USERS)

DEFAULT_PASSWORD = 'whatever' unless defined?(DEFAULT_PASSWORD)

unless Rails.env.development? || Rails.env.production? ||
       Rails.env.test?        || ENV['HEROKU_STAGING']

  puts 'Unknown Rails environment !!'
  abort SEED_STOP_MSG
end

puts ">>> SEEDING ENVIRONMENT: #{Rails.env}"


unless Region.exists?
  puts 'Loading regions'
  Rake::Task['shf:load_regions'].invoke
end

unless Kommun.exists?
  puts 'Loading kommuns'
  Rake::Task['shf:load_kommuns'].invoke
end

unless AdminOnly::FileDeliveryMethod.exists?
  puts 'Loading SHF app file delivery methods'
  Rake::Task['shf:load_file_delivery_methods'].invoke
end

puts 'Creating business categories'
business_categories = %w(Träning Psykologi Rehab Butik Trim Friskvård Dagis Pensionat Skola)
business_categories.each { |b_category| BusinessCategory.find_or_create_by(name: b_category) }
BusinessCategory.find_or_create_by(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.find_or_create_by(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')


init_generated_seeding_info


puts 'Creating admin user'

email = env_invalid_blank('SHF_ADMIN_EMAIL')
pwd = env_invalid_blank('SHF_ADMIN_PWD')

if Rails.env.production?
  begin
    User.create!(email: email, password: pwd, admin: true,
                 first_name: 'SHF', last_name: 'Admin')
  rescue => e
    puts e.inspect
    puts SEED_STOP_MSG
    raise
  end
else
  User.create(email: email, password: pwd, admin: true,
              first_name: 'SHF', last_name: 'Admin')
end

if Rails.env.development? || Rails.env.staging? || ENV['HEROKU_STAGING']

  Seeders::OrderedListEntriesSeeder.seed

  #
  # === USERS ===
  #
  number_of_users = (ENV['SHF_SEED_USERS'] || SEED_USERS).to_i
  puts "Creating #{number_of_users} additional users. (This number can be set with ENV['SHF_SEED_USERS'])..."

  users = {}
  while users.length < number_of_users - 1 do
    email = FFaker::InternetSE.disposable_email
    first_name = FFaker::NameSE.first_name
    last_name = FFaker::NameSE.last_name
    users[email] = User.create!(email: email, password: DEFAULT_PASSWORD,
                                first_name: first_name,
                                last_name: last_name) unless users.key?(email)
  end

  puts "Users now in the db: #{User.count}"

  # =================================


  #
  # === MEMBERSHIP APPLICATIONS ===
  #
  puts "\nCreating membership applications ..."
  puts "  If a company address must be created (instead of reading from a CSV file), it must be geocoded, which takes time.  Be patient."
  puts "  You can look at the /log/development.log to be sure that things are happening and this is not stuck."
  puts "  You can specify a CSV file of addresses to use in your .env file (.env.development etc.)."

  make_applications(users.values)

  puts "\n  Membership applications created: #{ShfApplication.count}"
  puts "  Membership Applications by state:"
  states = ShfApplication.aasm.states.map(&:name)
  states.sort.each do | state |
    puts "  #{state}: #{ShfApplication.where(state: state).count }"
  end

  # =================================


  #
  # === APPLICATION CONFIGURATION ===
  #

  if AdminOnly::AppConfiguration.count == 0
    puts "Seeding AppConfiguration..."
    SeedHelper::AppConfigurationSeeder.seed
  else
    puts "No AppConfiguration seeded.  One already exists."
    puts ' ... but there is no site meta image! You need to set one on the edit app configuration page (as an admin).' unless AdminOnly::AppConfiguration.last.site_meta_image.exists?
  end

end

puts SEED_COMPLETE_MSG
