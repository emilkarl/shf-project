require 'rails_helper'

ENV_ADMIN_EMAIL_KEY = 'SHF_ADMIN_EMAIL' unless defined?(ENV_ADMIN_EMAIL_KEY)
ENV_ADMIN_PASSWORD_KEY = 'SHF_ADMIN_PWD' unless defined?(ENV_ADMIN_PASSWORD_KEY)
ENV_NUM_SEEDED_USERS_KEY = 'SHF_SEED_USERS' unless defined?(ENV_NUM_SEEDED_USERS_KEY)
ENV_SEED_FAKE_CSV_FNAME_KEY = 'SHF_SEED_FAKE_ADDR_CSV_FILE' unless defined?(ENV_SEED_FAKE_CSV_FNAME_KEY)

#========================================================================================


RSpec.shared_examples 'admin, business categories, kommuns, and regions are seeded' do |rails_env, admin_email, admin_pwd|

  describe 'happy path - all is correct' do

    before(:all) do
      DatabaseCleaner.start

      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))
        allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )

        SHFProject::Application.load_tasks
        SHFProject::Application.load_seed
      end
    end

    after(:all) do
      DatabaseCleaner.clean
      Rake::Task['shf:load_regions'].reenable
      Rake::Task['shf:load_kommuns'].reenable
    end


    let(:admin_in_db) { User.find_by_email(admin_email) }

    it "#{admin_email} is in the db" do
      expect(admin_in_db).not_to be_nil
    end

    it 'admin is in the db' do
      expect(admin_in_db.admin).to be_truthy
    end

    it "admin email is = #{admin_email}" do
      expect(admin_in_db.email).to eq(admin_email)
    end

    it "admin password is in the db" do
      expect(admin_in_db.valid_password?(admin_pwd)).to be_truthy
    end

    it 'business categories are in the db' do
      expect(BusinessCategory.all.size).to eq(11)
    end

    it 'regions are in the db' do
      expect(Region.all.size).to eq(23)
    end

    it 'kommuns are in the db' do
      expect(Kommun.all.size).to eq(290)
    end

  end


  describe 'sad path: errors are raised' do

    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("#{rails_env}"))
        allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

        # must stub this way so the rest of ENV is preserved
        stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => admin_email,
                                             ENV_ADMIN_PASSWORD_KEY => admin_pwd}) )
      end
    end

    it 'admin email not found' do
      admin_email_value = ENV.delete(ENV_ADMIN_EMAIL_KEY)
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_EMAIL_KEY] = admin_email_value
    end

    it 'admin email is an empty string' do
      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_EMAIL_KEY => ''}) )
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end

    it 'admin password not found' do
      admin_password_value = ENV.delete(ENV_ADMIN_PASSWORD_KEY)
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
      ENV[ENV_ADMIN_PASSWORD_KEY] = admin_password_value
    end

    it 'admin password is an empty string' do
      stub_const('ENV', ENV.to_hash.merge({ENV_ADMIN_PASSWORD_KEY => ''}) )
      expect { Rails.application.load_seed }.to raise_exception SeedHelper::SeedAdminENVError
    end
  end

end



#========================================================================================


RSpec.shared_examples 'it calls geocode min max times with csv file' do |num_users, geocode_min, geocode_max, csv_filename|

  it "seed #{num_users}, calls Geocode.search at least #{geocode_min} and at most #{geocode_max} times" do


    RSpec::Mocks.with_temporary_scope do

      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

      stub_const('ENV', ENV.to_hash.merge({ ENV_NUM_SEEDED_USERS_KEY => num_users }))
      stub_const('ENV', ENV.to_hash.merge({ ENV_SEED_FAKE_CSV_FNAME_KEY => csv_filename }))

      if geocode_min == 0
        expect(Geocoder).to receive(:search).never
      else
        expect(Geocoder).to receive(:search).at_least(geocode_min).times
      end

      expect(Geocoder).to receive(:search).at_most(geocode_max).times if geocode_max > 0

      SHFProject::Application.load_seed

      expect(User.count).to eq num_users
      expect(Address.count).to eq Company.count
    end

  end
end
