#--------------------------
#
# @class PaymentsCoveringYearCsvReport
#
# @desc Responsibility: all info for a "payments covering any part of a given year" report.
#   Gathers all of the successful Payments that cover any part of the given year
#   - can return it in a CSV form
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/25/21
#
#--------------------------

class AdminOnly::Reports::PaymentsCoveringYearCsvReport < AdminOnly::Reports::CsvReport

  attr_accessor :year
  attr_reader :payments


  def self.csv_adapter
    Adapters::PaymentCoveringYearToCsvAdapter
  end


  # -----------------------------------------------------------------------------------------------

  def initialize(year = Date.current.year)
    @year = year.to_i
    super
  end

  def get_report_items(_args)
    @payments = Payment.includes(:user).includes(:company).completed.covering_year(year.to_i)
    @report_items = @payments.map { |payment| PaymentCoveringYear.new(payment: payment, year: year) }
  end


  def filename_start
    "framgangsrika-betalningar-#{year}"
  end


  def csv_header_args
    [year]
  end
end
