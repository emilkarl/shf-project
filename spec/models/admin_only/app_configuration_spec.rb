require 'rails_helper'
require 'shared_context/unstub_paperclip_file_commands'


RSpec.describe AdminOnly::AppConfiguration, type: :model do

  # These are required to get the content type and validate it
  include_context 'unstub Paperclip file commands'

  # do not use the mock; use the real thing
  before(:each) { allow(AdminOnly::AppConfiguration).to receive(:config_to_use).and_call_original }


  let(:app_configuration) { create(:app_configuration) }

  PHOTOS_PATH = File.join(Rails.root, 'spec', 'fixtures', 'member_photos')

  let(:txt_file)  { File.new(File.join(PHOTOS_PATH, 'text_file.jpg')) }
  let(:gif_file)  { File.new(File.join(PHOTOS_PATH, 'gif_file.jpg')) }
  let(:ico_file)  { File.new(File.join(PHOTOS_PATH, 'ico_file.png')) }
  let(:xyz_file)  { File.new(File.join(PHOTOS_PATH, 'member_with_dog.xyz')) }

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:app_configuration)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :chair_signature_file_name }
    it { is_expected.to have_db_column :chair_signature_content_type }
    it { is_expected.to have_db_column :chair_signature_file_size }
    it { is_expected.to have_db_column :chair_signature_updated_at }
    it { is_expected.to have_db_column :shf_logo_file_name }
    it { is_expected.to have_db_column :shf_logo_content_type }
    it { is_expected.to have_db_column :shf_logo_file_size }
    it { is_expected.to have_db_column :shf_logo_updated_at }
    it { is_expected.to have_db_column :h_brand_logo_file_name }
    it { is_expected.to have_db_column :h_brand_logo_content_type }
    it { is_expected.to have_db_column :h_brand_logo_file_size }
    it { is_expected.to have_db_column :h_brand_logo_updated_at }
    it { is_expected.to have_db_column :sweden_dog_trainers_file_name }
    it { is_expected.to have_db_column :sweden_dog_trainers_content_type }
    it { is_expected.to have_db_column :sweden_dog_trainers_file_size }
    it { is_expected.to have_db_column :sweden_dog_trainers_updated_at }
    it { is_expected.to have_db_column :email_admin_new_app_received_enabled }
    it { is_expected.to have_db_column :site_name }
    it { is_expected.to have_db_column :site_meta_title }
    it { is_expected.to have_db_column :site_meta_description }
    it { is_expected.to have_db_column :site_meta_keywords }
    it { is_expected.to have_db_column :og_type }
    it { is_expected.to have_db_column :twitter_card_type }
    it { is_expected.to have_db_column :facebook_app_id }
    it { is_expected.to have_db_column :site_meta_image_file_name }
    it { is_expected.to have_db_column :site_meta_image_content_type }
    it { is_expected.to have_db_column :site_meta_image_file_size }
    it { is_expected.to have_db_column :site_meta_image_updated_at }
    it { is_expected.to have_db_column :site_meta_image_height }
    it { is_expected.to have_db_column :site_meta_image_width }
    it { is_expected.to have_db_column :singleton_guard }
    it { is_expected.to have_db_column :payment_too_soon_days }
  end


  describe 'Validations' do

    it { is_expected.to validate_inclusion_of(:singleton_guard).in_array([0]) }
    it { is_expected.to validate_presence_of(:site_name) }
    it { is_expected.to validate_presence_of(:site_meta_title) }

    describe 'image attachments' do

      image_attachments = [:chair_signature,
                           :shf_logo,
                           :h_brand_logo,
                           :sweden_dog_trainers,
                           :site_meta_image
      ]

      image_attachments.each do |image_attachment|

        describe "content type for #{image_attachment}" do

          it "'image/png', 'image/jpg' are valid, 'image/gif', 'image/bmp' are not" do
            is_expected.to validate_attachment_content_type(image_attachment)
                               .allowing('image/png', 'image/jpeg')
                               .rejecting('image/gif', 'image/bmp')
          end

          it "is not valid if content is text, gif, ico, or a file type <> jpg or png" do
            app_configuration.send("#{image_attachment}=", txt_file)
            expect(app_configuration).not_to be_valid

            app_configuration.send("#{image_attachment}=", gif_file)
            expect(app_configuration).not_to be_valid

            app_configuration.send("#{image_attachment}=", ico_file)
            expect(app_configuration).not_to be_valid
          end

          it 'rejects if content type is ok but file type is wrong' do
            app_configuration.send("#{image_attachment}=", xyz_file)
            expect(app_configuration).not_to be_valid
          end
        end

      end

      it 'site meta image must be present' do
        is_expected.to validate_attachment_presence('site_meta_image')
      end
    end

  end


  describe 'is a Singleton' do

    it 'is always the same AppConfiguration no matter how you fetch it' do
      app_configuration.save
      expect(described_class.first).to eq(app_configuration)
      expect(described_class.last).to eq(app_configuration)
      expect(described_class.instance).to eq(app_configuration)
      expect(described_class.config_to_use).to eq(app_configuration)
    end

    it 'cannot create more than one' do
      new_config = described_class.new

      # we have to have a site_meta_image, so just use what already exists:
      new_config.site_meta_image = app_configuration.site_meta_image

      expect{new_config.save!}.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end


  describe 'update_site_meta_image_info' do

    describe 'updates the width and height if site_meta_image was changed' do

      it 'site_meta_image changed' do
        expect(app_configuration).to receive(:update_site_meta_image_dimensions)

        app_configuration.site_meta_image = File.new(file_fixture('image.png'))
        app_configuration.save
      end


      it 'site_meta_image not changed' do
        expect(app_configuration).not_to receive(:update_site_meta_image_dimensions)

        # make a change to the app_configuration that is not about the site image
        app_configuration.email_admin_new_app_received_enabled = false
        app_configuration.save
      end
    end

  end

end
