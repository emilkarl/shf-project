class AddMembershipExpiredGracePeriodDurationToAppConfiguration < ActiveRecord::Migration[5.2]
  def change

    add_column :app_configurations, :membership_expired_grace_period_duration, :string, default: 'P90D', null: false, comment: "Duration after membership expiration that a member can pay without penalty. ISO 8601 Duration string format. Must be used so we can handle leap years"
  end
end
