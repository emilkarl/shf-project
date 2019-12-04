class AddSocialMediaToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :facebook_url, :string
    add_column :companies, :instagram_url, :string
    add_column :companies, :youtube_url, :string
  end
end
