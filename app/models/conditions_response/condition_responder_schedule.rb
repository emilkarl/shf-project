#--------------------------
#
# @class ConditionResponderSchedule
#
# @desc Responsibility: represent the schedule for a condition
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-08-14
#
#--------------------------

class ConditionResponderSchedule


  TIMING_BEFORE    = :before
  TIMING_AFTER     = :after
  TIMING_ON        = :on
  TIMING_EVERY_DAY = :every_day
  TIMING_DAY_OF_MONTH = :day_of_month

  ALL_TIMINGS = [TIMING_BEFORE, TIMING_AFTER, TIMING_ON, TIMING_EVERY_DAY]

  DEFAULT_TIMING = TIMING_ON


  def self.default_schedule
    DEFAULT_TIMING
  end

  # Determine the number of days today is _away_from_ this date.
  # The :timing is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from today.
  #
  # @param this_date [Date] - the date to compare to today
  # @param timing [Timing] - which 'direction' (before, after, on) to compare to today
  # @return [Integer] - the number of days away from today, based on our :timing
  def self.days_today_is_away_from(this_date, timing)
    days_1st_date_is_from_2nd(Date.current, this_date, timing)
  end


  # Determine the number of days :a_date is _away_from_ :second_date.
  # The :timing is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from :a_date.
  #
  # @param a_date [Date] - the starting date
  # @param second_date [Date] - the date to compare to :a_date
  # @param timing [Timing] - which 'direction' (before, after, on) to compare to :a_date
  # @return [Integer] - the number of days separating the two dates, based on the :timing
  def self.days_1st_date_is_from_2nd(a_date, second_date, timing)

    day_num_to_check = 0 # default value

    # We use .to_date to ensure that we're comparing and working with Dates, not Times, etc.
    # If calling .to_date throws an exception, that's an exception that should be raised.

    if timing_is_before?(timing)
      # number of days that a_date is _before_ second_date
      day_num_to_check = second_date.to_date - a_date.to_date

    elsif timing_is_after?(timing)
      # number of days that a_date is _after_ second_date
      day_num_to_check = a_date.to_date - second_date.to_date
    end

    day_num_to_check.to_i
  end


  def self.timing_is_before?(timing)
    timing == TIMING_BEFORE
  end


  def self.timing_is_after?(timing)
    timing == TIMING_AFTER
  end


  def self.timing_is_on?(timing)
    timing == TIMING_ON
  end


  def self.timing_is_every_day?(timing)
    timing == TIMING_EVERY_DAY
  end


  def self.timing_is_day_of_month?(timing)
    timing == TIMING_DAY_OF_MONTH
  end


  # True if the timing is every day
  # OR if it is set to a day of the month and today is that day
  def self.timing_matches_today?(timing, config)
    timing_is_every_day?(timing) || today_is_timing_day_of_month?(timing, config)
  end


  # True if the timing is for the day of a month
  # and today is the day of the month specified in the config
  def self.today_is_timing_day_of_month?(timing, config)
    self.timing_is_day_of_month?(timing) &&
        config.fetch(:on_month_day, false) &&
        config[:on_month_day] == Date.current.day
  end


  def self.all_timings
    ALL_TIMINGS
  end

end
