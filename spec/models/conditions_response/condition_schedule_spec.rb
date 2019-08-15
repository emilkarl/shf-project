require 'rails_helper'

require 'shared_context/activity_logger'


RSpec.describe ConditionSchedule, type: :model do

  include_context 'create logger'


  let(:default_timing_schedule) { described_class.new(described_class.default_timing) }


  it 'default_schedule is  :on' do
    expect(described_class.default_schedule).to eq :on
  end


  describe 'class timing predicate methods' do

    describe '.timing_is_before?(timing)' do

      it 'returns true if timing is before' do
        schedule = described_class.new(described_class.timing_before)
        expect(described_class.timing_is_before?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_before]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_before?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end
    end

    describe '.timing_is_after?(timing)' do
      it 'returns true if timing is after' do
        schedule = described_class.new(described_class.timing_after)
        expect(described_class.timing_is_after?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_after]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_after?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end
    end


    describe '.timing_is_on?(timing)' do

      it 'returns true if timing is on' do
        schedule = described_class.new(described_class.timing_on)
        expect(described_class.timing_is_on?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_on]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_on?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end
    end


    describe '.timing_is_every_day?(timing)' do

      it 'returns true if timing == :every_day' do
        schedule = described_class.new(described_class.timing_every_day)
        expect(described_class.timing_is_every_day?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_every_day]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_every_day?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end
    end

    describe '.timing_is_day_of_month?' do

      it 'true if timing == :day_of_month' do
        schedule = described_class.new(described_class.timing_day_of_month)
        expect(described_class.timing_is_day_of_month?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_day_of_month]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_day_of_month?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end
    end


    describe '.timing_is_repeating?' do
      it 'true if timing == :day_of_month' do
        schedule = described_class.new(described_class.timing_repeating)
        expect(described_class.timing_is_repeating?(schedule)).to be true
      end

      other_timings = described_class.all_timings - [described_class.timing_repeating]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.timing_is_repeating?(described_class.new(described_class.new(timing))) ).to be_falsey
        end
      end

    end

  end


  describe '.timing_matches_today?' do

    it 'true if timing is every day' do
      schedule = described_class.new(described_class.timing_every_day)
      config = {}
      expect(described_class.timing_matches_today?(schedule, config)).to be true
    end

    it 'true if today is the timing day of month? ' do
      schedule = described_class.new(described_class.timing_day_of_month)
      config = { on_month_day: Date.current.day }
      expect(described_class.timing_matches_today?(schedule, config)).to be true
    end

    it 'false otherwise' do
      config = {}
      expect(described_class.timing_matches_today?(default_timing_schedule, config)).to be false
    end
  end


  describe '.today_is_timing_day_of_month?' do

    let(:day_of_month_schedule) { described_class.new(described_class.timing_day_of_month) }


    it "true if timing is day of month AND config[:on_month_day] is today's day of the month" do
      config = { on_month_day: Date.current.day }
      expect(described_class.today_is_timing_day_of_month?(day_of_month_schedule, config)).to be true
    end

    it 'false if :on_month_day is not in config' do
      config = {}
      expect(described_class.today_is_timing_day_of_month?(day_of_month_schedule, config)).to be false
    end

    it "false if on_month_day is not today's date" do
      config = { on_month_day: Date.current.day - 1 }
      expect(described_class.today_is_timing_day_of_month?(day_of_month_schedule, config)).to be false
    end

    it 'false if timing is not day of month' do
      timings = described_class.all_timings - [described_class.timing_day_of_month]
      timings.each do | timing |
        not_day_of_mon_sched = described_class.new(described_class.default_timing)
        config = { on_month_day: Date.current.day }
        expect(described_class.today_is_timing_day_of_month?(not_day_of_mon_sched, config))
      end
    end
  end


  describe 'instance timing queries' do

    describe 'before?' do

      it 'true if timing (direction) is before' do
        expect(described_class.new(described_class.timing_before).before?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_before]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).before?).to be_falsey
        end
      end
    end

    describe 'after?' do
      it 'true if timing (direction) is after' do
        expect(described_class.new(described_class.timing_after).after?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_after]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).after?).to be_falsey
        end
      end
    end

    describe 'on?' do
      it 'true if timing (direction) is after' do
        expect(described_class.new(described_class.timing_on).on?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_on]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).on?).to be_falsey
        end
      end
    end

    describe 'every_day?' do
      it 'true if timing (direction) is every day' do
        expect(described_class.new(described_class.timing_every_day).every_day?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_every_day]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).every_day?).to be_falsey
        end
      end
    end

    describe 'day_of_month?' do
      it 'true if timing (direction) is day of month' do
        expect(described_class.new(described_class.timing_day_of_month).day_of_month?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_day_of_month]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).day_of_month?).to be_falsey
        end
      end
    end

    describe 'repeating?' do
      it 'true if timing (direction) is repeating' do
        expect(described_class.new(described_class.timing_repeating).repeating?).to be_truthy
      end

      other_timings = described_class.all_timings - [described_class.timing_repeating]
      other_timings.each do | timing |
        it "false if #{timing}" do
          expect(described_class.new(timing).repeating?).to be_falsey
        end
      end
    end
  end


  describe '#on_day_of_month?' do

    let(:day_of_month_schedule) { described_class.new(described_class.timing_day_of_month) }


    it "true if timing is day of month AND the day of the month is today" do
      expect(day_of_month_schedule.on_day_of_month?(Date.current.day)).to be_truthy
    end

    it 'false if the day of the month is nil' do
      expect(day_of_month_schedule.on_day_of_month?(nil)).to be_falsey
    end

    it "false if the day of the month is not today's date" do
      expect(day_of_month_schedule.on_day_of_month?(Date.current.day - 1)).to be_falsey
    end

    it 'false if timing is not day of month' do
      timings = described_class.all_timings - [described_class.timing_day_of_month]
      timings.each do | timing |
        not_day_of_mon_sched = described_class.new(timing)
        expect(not_day_of_mon_sched.on_day_of_month?(Date.current.day)).to be_falsey
      end
    end
  end


  describe '#matches_today?' do

    it 'true if timing is every day' do
      schedule = described_class.new(described_class.timing_every_day)
      expect(schedule.matches_today?(Date.current.day + 1)).to be_truthy
    end

    it 'true if today is given date of the month' do
      schedule = described_class.new(described_class.timing_day_of_month)
      config = { on_month_day: Date.current.day }
      expect(schedule.matches_today?(Date.current.day)).to be_truthy
    end

    it 'false if the timing is anything else' do
      date = Date.current.day

      timings = described_class.all_timings - [described_class.timing_every_day]
      timings.each do | timing |
        not_day_of_mon_sched = described_class.new(timing)
        expect(not_day_of_mon_sched.matches_today?(date)).to be_falsey
      end
    end
  end

end
