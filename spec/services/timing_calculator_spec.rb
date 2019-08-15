require 'rails_helper'

RSpec.describe TimingCalculator do


  let(:timing_before) { ConditionSchedule.timing_before }
  let(:timing_after) { ConditionSchedule.timing_after }
  let(:timing_on) { ConditionSchedule.timing_on }


  let(:nov_30) { Date.new(2018, 11, 30) }
  let(:dec_1) { Date.new(2018, 12, 1) }
  let(:dec_2) { Date.new(2018, 12, 2) }


  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.days_a_date_is_away_from is the number of days today is _away_from_ this date.' do

    describe 'timing_direction is before' do

      it '1st is 1 day before 2nd date  = 1' do
        expect(described_class.days_1st_date_is_from_2nd(nov_30, dec_1, timing_before)).to eq 1
      end

      it '1st = 2nd date  == 0' do
        expect(described_class.days_1st_date_is_from_2nd(dec_1, dec_1, timing_before)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = -1' do
        expect(described_class.days_1st_date_is_from_2nd(dec_2, dec_1, timing_before)).to eq -1
      end

    end

    context 'timing_direction is after' do

      it '1st is 1 day before 2nd date  = -1' do
        expect(described_class.days_1st_date_is_from_2nd(nov_30, dec_1, timing_after)).to eq -1
      end

      it '1st = 2nd date  == 0' do
        expect(described_class.days_1st_date_is_from_2nd(dec_1, dec_1, timing_after)).to eq 0
      end

      it '1st date is 1 day after 2nd date  = 1' do
        expect(described_class.days_1st_date_is_from_2nd(dec_2, dec_1, timing_after)).to eq 1
      end

    end


    context 'timing_direction is on (always returns 0 days away; this means always check on the 2nd date no matter how many days away)' do

      it '2nd date is 1 day before the date = 0' do
        expect(described_class.days_1st_date_is_from_2nd(dec_1, nov_30, timing_on)).to eq 0
      end

      it '2nd date is == the date = 0' do
        expect(described_class.days_1st_date_is_from_2nd(dec_1, dec_1, timing_on)).to eq 0
      end

      it '2nd date is 1 day after the date = 0' do
        expect(described_class.days_1st_date_is_from_2nd(dec_1, dec_2, timing_on)).to eq 0
      end

    end

  end


  describe '.days_today_is_away_from(timing, some_date)' do

    context 'timing_direction is before' do

      it 'today is 1 day before the date = described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_before)' do
        expect(described_class.days_today_is_away_from(nov_30, timing_before)).to eq described_class.days_1st_date_is_from_2nd(dec_1, nov_30, timing_before)
      end

      it 'today = the date = described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)' do
        expect(described_class.days_today_is_away_from(dec_1, timing_before)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_before)
      end

      it 'today is 1 day after the date = described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)' do
        expect(described_class.days_today_is_away_from(dec_2, timing_before)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_before)
      end

    end

    context 'timing_direction is after' do

      it 'today is 1 day after the date = described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)' do
        expect(described_class.days_today_is_away_from(dec_2, timing_after)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)
      end

      it 'date is on today = described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)' do
        expect(described_class.days_today_is_away_from(dec_1, timing_after)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)
      end

      it 'today is 1 day before the date = described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)' do
        expect(described_class.days_today_is_away_from(nov_30, timing_after)).to eq described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)
      end

    end


    context 'timing_direction is on (always returns 0 days away; this means always check on today)' do

      it 'date is 1 day before today = described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)' do
        expect(described_class.days_today_is_away_from(nov_30, timing_on)).to eq described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_on)
      end

      it 'date is on today = described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)' do
        expect(described_class.days_today_is_away_from(dec_1, timing_on)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_on)
      end

      it 'date is 1 day after today = described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)' do
        expect(described_class.days_today_is_away_from(dec_2, timing_on)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_on)
      end

    end

  end

end
