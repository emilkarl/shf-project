#--------------------------
#
# @class PaymentsCsvReport
#
# @desc Responsibility: CSV report for all Payments
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/25/21
#
#--------------------------

class AdminOnly::Reports::PaymentsCsvReport < AdminOnly::Reports::CsvReport

  def self.csv_adapter
    Adapters::PaymentToCsvAdapter
  end


  # -----------------------------------------------------------------------------------------------

  def get_report_items(_args)
    Payment.includes(:user).includes(:company).all
  end


  def filename_start
    'betalningar'
  end
end
