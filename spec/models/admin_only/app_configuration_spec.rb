require 'rails_helper'
require 'shared_context/unstub_paperclip_file_commands'


RSpec.describe AdminOnly::AppConfiguration, type: :model do

  # These are required to get the content type and validate it
  include_context 'unstub Paperclip file commands'

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
  end


  describe 'Validations' do

    describe 'image attachments' do

      image_attachments = [:chair_signature,
                           :shf_logo,
                           :h_brand_logo,
                           :sweden_dog_trainers
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

    end

  end

end
