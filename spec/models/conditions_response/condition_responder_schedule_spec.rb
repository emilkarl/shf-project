require 'rails_helper'

require 'shared_context/activity_logger'


RSpec.describe ConditionResponderSchedule, type: :model do

  include_context 'create logger'


  it 'DEFAULT_TIMING is :on' do
    expect(described_class::DEFAULT_TIMING).to eq :on
  end


  describe '.days_a_date_is_away_from(a_date, timing, some_date)' do

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { described_class::TIMING_BEFORE }

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

    context 'timing is after' do

      let(:timing_after) { described_class::TIMING_AFTER }

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


    context 'timing is on (always returns 0 days away; this means always check on the 2nd date no matter how many days away)' do

      let(:timing_on) { described_class::TIMING_ON }

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

    let(:nov_30) { Date.new(2018, 11, 30) }
    let(:dec_1)  { Date.new(2018, 12,  1) }
    let(:dec_2)  { Date.new(2018, 12,  2) }

    around(:each) do |example|
      Timecop.freeze(dec_1)
      example.run
      Timecop.return
    end


    context 'timing is before' do

      let(:timing_before) { described_class::TIMING_BEFORE }

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

    context 'timing is after' do

      let(:timing_after) { described_class::TIMING_AFTER }

      it 'today is 1 day after the date = described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)' do
        expect(described_class.days_today_is_away_from(dec_2, timing_after)).to eq  described_class.days_1st_date_is_from_2nd(Date.current, dec_2, timing_after)
      end

      it 'date is on today = described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)' do
        expect(described_class.days_today_is_away_from(dec_1, timing_after)).to eq described_class.days_1st_date_is_from_2nd(Date.current, dec_1, timing_after)
      end

      it 'today is 1 day before the date = described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)' do
        expect(described_class.days_today_is_away_from(nov_30, timing_after)).to eq described_class.days_1st_date_is_from_2nd(Date.current, nov_30, timing_after)
      end

    end


    context 'timing is on (always returns 0 days away; this means always check on today)' do

      let(:timing_on) { described_class::TIMING_ON }

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

  describe 'timing predicate methods' do

    describe '.timing_is_before?(timing)' do

      it 'returns true if timing == TIMING_BEFORE' do
        timing = described_class::TIMING_BEFORE
        expect(described_class.timing_is_before?(timing)).to be true
      end

      it 'returns false otherwise' do
        timing = described_class::DEFAULT_TIMING
        expect(described_class.timing_is_before?(timing)).to be false
      end
    end


    describe '.timing_is_after?(timing)' do
      it 'returns true if timing == :after' do
        timing = described_class::TIMING_AFTER
        expect(described_class.timing_is_after?(timing)).to be true
      end

      it 'returns false otherwise' do
        timing = described_class::DEFAULT_TIMING
        expect(described_class.timing_is_after?(timing)).to be false
      end
    end


    describe '.timing_is_on?(timing)' do
      it 'returns true if timing == :on' do
        timing = described_class::TIMING_ON
        expect(described_class.timing_is_on?(timing)).to be true
      end

      it 'returns false otherwise' do
        timing = :not_on
        expect(described_class.timing_is_on?(timing)).to be false
      end
    end


    describe '.timing_is_every_day?(timing)' do

      it 'returns true if timing == :every_day' do
        timing = described_class::TIMING_EVERY_DAY
        expect(described_class.timing_is_every_day?(timing)).to be true
      end

      it 'returns false otherwise' do
        timing = described_class::DEFAULT_TIMING
        expect(described_class.timing_is_every_day?(timing)).to be false
      end

    end

    describe '.timing_is_day_of_month?' do

      it 'true if timing == :day_of_month' do
        timing = described_class::TIMING_DAY_OF_MONTH
        expect(described_class.timing_is_day_of_month?(timing)).to be true
      end

      it 'false otherwise' do
        timing = described_class::DEFAULT_TIMING
        expect(described_class.timing_is_day_of_month?(timing)).to be false
      end
    end

  end


  describe '.timing_matches_today?' do

    it 'true if timing is every day' do
      timing = described_class::TIMING_EVERY_DAY
      config = {}
      expect(described_class.timing_matches_today?(timing, config)).to be true
    end

    it 'true if today is the timing day of month? ' do
      timing = described_class::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day}
      expect(described_class.timing_matches_today?(timing, config)).to be true
    end

    it 'false otherwise' do
      timing = described_class::DEFAULT_TIMING
      expect(described_class.timing_matches_today?(timing, config)).to be false
    end
  end


  describe '.today_is_timing_day_of_month?' do

    it "true if timing is day of month AND config[:on_month_day] is today's day of the month" do
      timing = described_class::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day}
      expect(described_class.today_is_timing_day_of_month?(timing, config)).to be true
    end

    it 'false if :on_month_day is not in config' do
      timing = described_class::TIMING_DAY_OF_MONTH
      config = {}
      expect(described_class.today_is_timing_day_of_month?(timing, config)).to be false
    end

    it "false if on_month_day is not today's date" do
      timing = described_class::TIMING_DAY_OF_MONTH
      config = {on_month_day: Date.current.day - 1}
      expect(described_class.today_is_timing_day_of_month?(timing, config)).to be false
    end

  end

end
