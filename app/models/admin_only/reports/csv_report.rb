#--------------------------
#
# @class CsvReport
#
# @desc Responsibility: Common behavior for all reports that can be saved as a CSV file.
#   - returns the file name
#   - returns the information as a String with a header and each item as a line with comma separated values (CSVs)
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/25/21
#
#--------------------------

class AdminOnly::Reports::CsvReport

  attr_writer :report_items

  # Subclasses MUST define this
  def self.csv_adapter
    raise NoMethodError "Subclasses must define #{__method__}"
  end


  # -----------------------------------------------------------------------------------------------

  def initialize(*args)
    @report_items = get_report_items(args)
  end


  def to_csv
    items_exported_as_csv(report_items, self.class.csv_adapter, csv_header)
  end


  # Subclasses must override this method to set the report_items
  def get_report_items(_args)
    raise NoMethodError, "Subclasses must define #{__method__} and set the report items"
  end

  def csv_header
    self.class.csv_adapter.header_str(*csv_header_args)
  end


  # Subclasses can overwrite this to pass in arguments to the adaper class.  ex:
  # pass in a year value:
  #    def csv_header_args
  #      [year]
  #    end
  #
  # @return [Array] - the array of arguments to pass to the adapter .header_str method
  def csv_header_args
    []
  end


  def items_exported_as_csv(items = [], csv_adapter = nil, header_str = '')
    out_str = '' << header_str
    items.each do |item|
      out_str << csv_adapter.new(item).as_target.to_s unless csv_adapter.nil?
      out_str << "\n"
    end
    out_str.encode('UTF-8')
  end


  def csv_filename
    "#{filename_start}--#{Time.zone.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"
  end


  # Subclasses should provide a more meaningful string
  def filename_start
    'rapportera'
  end


  def report_items
    @report_items ||= []
  end
end

