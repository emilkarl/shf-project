APP_CONFIG_FIXTURES = Rails.root.join('spec', 'fixtures', 'app_configuration') unless defined?(APP_CONFIG_FIXTURES)

FactoryBot.define do

  factory :app_configuration, class: AdminOnly::AppConfiguration do

    site_name { 'Site Name' }
    site_meta_title { 'Site meta title' }
    site_meta_description { 'Site meta description' }
    site_meta_keywords { 'site meta keywords keyword4 keyword5' }
    og_type { 'og type' }
    twitter_card_type { 'twitter card type'}
    facebook_app_id { 1234567890 }


    chair_signature do
      File.new(File.join(APP_CONFIG_FIXTURES, 'chair_signature.png'))
    end

    shf_logo do
      File.new(File.join(APP_CONFIG_FIXTURES, 'shf_logo.png'))
    end

    h_brand_logo do
      File.new(File.join(APP_CONFIG_FIXTURES, 'h_brand_logo.png'))
    end

    sweden_dog_trainers do
      File.new(File.join(APP_CONFIG_FIXTURES, 'sweden_dog_trainers.png'))
    end

    site_meta_image do
      File.new(File.join(APP_CONFIG_FIXTURES, 'Sveriges_hundforetagare_banner_sajt.jpg'))
    end

    site_meta_image_width { 1245 }
    site_meta_image_height { 620 }

  end
end
