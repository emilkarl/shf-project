class AddApplyQsLinkToBusinessCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :business_categories, :apply_qs_url, :string, comment: 'URL for gathering additional info when applicant applies for this category'
  end
end
