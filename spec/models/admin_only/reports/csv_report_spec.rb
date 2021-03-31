require 'rails_helper'

RSpec.describe AdminOnly::Reports::CsvReport, type: :model do

  let(:stand_in_adapter) { Adapters::PaymentCoveringYearToCsvAdapter }
  let(:header_line) { "this, is, the,csv,header,line\n" }

  before(:each) { allow_any_instance_of(described_class).to receive(:get_report_items).and_return([]) }


  describe '.csv_adapter' do
    it 'raises a NoMethodError because subclasses must define this' do
      expect { described_class.csv_adapter }.to raise_error(NoMethodError)
    end
  end

  it 'new will call get_report_items to give subclasses a way to set the list of report items' do
    expect_any_instance_of(described_class).to receive(:get_report_items).and_return(true)
    described_class.new
  end

  it 'get_report_items raises NoMethodError because subclasses must override this' do
    allow_any_instance_of(described_class).to receive(:get_report_items).and_call_original
    expect{subject.get_report_items(nil)}.to raise_error(NoMethodError)
  end


  describe 'to_csv' do
    it 'calls items_exported_as_csv with the report items, adapter class to use, and header line' do
      report_items = ['a', 'b']
      subject.report_items = report_items

      expect(described_class).to receive(:csv_adapter).and_return('faux_adapter')
      expect(subject).to receive(:csv_header).and_return(header_line)
      expect(subject).to receive(:items_exported_as_csv)
                          .with(report_items, 'faux_adapter', header_line)
      subject.to_csv
    end
  end

  describe 'csv_header' do
    it 'passes the csv_header args to the header_str method of the adapter' do
      header_args = [2, 'argument', :values]
      allow(described_class).to receive(:csv_adapter).and_return(stand_in_adapter)
      allow(subject).to receive(:csv_header_args).and_return(header_args)

      expect(described_class.csv_adapter).to receive(:header_str).with(*header_args)
      subject.csv_header
    end
  end

  describe 'csv_header_args' do
    it 'defaults to no args (an empty list of args)' do
      expect(subject.csv_header_args).to eq []
    end
  end

  describe 'items_exported_as_csv' do

    it 'starts with the header string' do
      allow(subject).to receive(:csv_header).and_return(header_line)
      expect(subject.items_exported_as_csv([], nil, header_line)).to match(/^#{header_line}/)
    end

    it 'goes through the given items and uses the adapter class to generate a CSV line for each' do
      faux_target = double(as_target: 'some,resulting,values,for,the,item')
      faux_adapter = double(stand_in_adapter)

      faux_target_csv_line = "some,resulting,values,for,the,item\n"

      expect(faux_adapter).to receive(:new).exactly(3).times.and_return(faux_target)
      expect(subject.items_exported_as_csv([1, 2, 3], faux_adapter, header_line))
        .to match(/#{header_line}#{faux_target_csv_line}#{faux_target_csv_line}#{faux_target_csv_line}/)
    end

    it 'encodes the string as UTF-8' do
      expect(subject.items_exported_as_csv.encoding.to_s).to eq 'UTF-8'
    end
  end


  describe 'csv_filename' do
    it 'is the start string, 2 dashes then a timestamp' do
      start_str = 'FantasticReport'
      allow(subject).to receive(:filename_start).and_return(start_str)

      travel_to Time.parse("2021-01-25 01:03:04 -0100") do
        expect(subject.csv_filename).to match(/#{start_str}--2021-01-25--02-03-04/)
      end
    end

    it 'extension is csv' do
      expect(subject.csv_filename.split('.').last).to eq 'csv'
    end
  end


  describe 'filename_start' do
    it "is 'rapportera'. Subclasses should provide something more specific and meaningful" do
      expect(subject.filename_start).to eq 'rapportera'
    end
  end


  describe 'report_items' do
    it 'is an empty list. Subclasses should set this to the list of things to convert (adapt) to CSV lines' do
      expect(subject.report_items).to eq []
    end
  end

end
