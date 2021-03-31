class AddMembershipTermLengthToAppConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configurations, :membership_term_length, :integer, default: 365, null: false, comment: "Number of days for a membership term"
  end
end
