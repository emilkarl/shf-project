require 'ice_cube'

#--------------------------
#
# @class ConditionSchedule
#
# @desc Responsibility: represent the schedule for a condition
#
# store a serialized version of this in the 'timing' attribute of a Condition (for now)
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-08-14
#
#--------------------------

class ConditionSchedule

  serialize :schedule, IceCube::Schedule


  TIMING_BEFORE = :before
  TIMING_AFTER = :after
  TIMING_ON = :on
  TIMING_EVERY_DAY = :every_day
  TIMING_DAY_OF_MONTH = :day_of_month
  REPEATING = :repeating

  DEFAULT_TIMING = TIMING_ON

  ALL_TIMINGS = [TIMING_BEFORE, TIMING_AFTER, TIMING_ON, TIMING_EVERY_DAY, REPEATING]

  DEFAULT_RULE = IceCube::Rule.daily(2)

  DEFAULT_SCHEDULE = TIMING_ON

  std_reminder_after_schedule = [2, 9, 14, 30, 60]

  std_reminder_before_schedule = [60, 30, 14, 2]


  attr_accessor :schedule, :timing


  def initialize(timing_key = self.class.default_timing)
    @timing = timing_key
    @schedule = IceCube::Schedule.new(Time.now.utc)
  end


  # add these days to the schedule.
  def add_days(days_list, timing = self.class.timing_on)
    start_time = schedule.start_time
    secs_in_day = 60*60*24  # number of seconds in a day
    days_list.each do | days_from_sched_start |
      schedule.add_recurrence_time(start_time + (days_from_sched_start * secs_in_day) )
    end

  end


  def self.default_timing
    DEFAULT_TIMING
  end


  def self.timing_before
    TIMING_BEFORE
  end


  def self.timing_after
    TIMING_AFTER
  end


  def self.timing_on
    TIMING_ON
  end


  def self.timing_every_day
    TIMING_EVERY_DAY
  end


  def self.timing_day_of_month
    TIMING_DAY_OF_MONTH
  end


  def self.timing_repeating
    REPEATING
  end


  def self.all_timings
    ALL_TIMINGS
  end


  # True if the timing is every day
  # OR if it is set to a day of the month and today is that day
  def self.timing_matches_today?(timing, config)
    timing.matches_today?(config[:on_month_day])
  end


  # True if the timing is for the day of a month
  # and today is the day of the month specified in the config
  def self.today_is_timing_day_of_month?(timing, config)
    timing.on_day_of_month?(config[:on_month_day])
  end


  def self.timing_is_before?(timing)
    timing.before?
  end


  def self.timing_is_after?(timing)
    timing.after?
  end


  def self.timing_is_on?(timing)
    timing.on?
  end


  def self.timing_is_every_day?(timing)
    timing.every_day?
  end


  def self.timing_is_day_of_month?(timing)
    timing.day_of_month?
  end

  def self.timing_is_repeating?(timing)
    timing.repeating?
  end


  def before?
    @timing == TIMING_BEFORE
  end


  def after?
    @timing == TIMING_AFTER
  end


  def on?
    @timing == TIMING_ON
  end


  def every_day?
    @timing == TIMING_EVERY_DAY
  end


  def day_of_month?
    @timing == TIMING_DAY_OF_MONTH
  end


  def repeating?
    @timing == REPEATING
  end


  # True if the timing is for the day of a month
  # and today is the day of the month given
  def on_day_of_month?(this_day_of_month)
    day_of_month? && this_day_of_month == Date.current.day
  end


  # True if the timing is every day
  # OR if it is set to a day of the month and today is that day
  def matches_today?(day_of_month)
    every_day? || on_day_of_month?(day_of_month)
  end
end
