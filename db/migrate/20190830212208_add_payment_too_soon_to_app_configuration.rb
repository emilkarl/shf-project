class AddPaymentTooSoonToAppConfiguration < ActiveRecord::Migration[5.2]

  def change
    add_column :app_configurations, :payment_too_soon_days, :integer,
               default: 60, null: false, comment: 'Warn user that they are paying too soon if payment is due more than this many days away.'
  end
end
