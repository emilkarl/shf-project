#--------------------------
#
# @class ConditionScheduleCalculator
#
# @desc Responsibility: calculates time between two dates, giving a :timing_direction:
# The :timing_direction is whether we are calculating the number of days
# _before_, _after_, or _on_ this day, starting from today.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-08-14
#
#--------------------------
#
class TimingCalculator


  # Determine the number of days today is _away_from_ this date.
  #
  # @param this_date [Date] - the date to compare to today
  # @param timing_direction [Symbol] - which 'direction' (before, after, on) to compare to today
  # @return [Integer] - the number of days away from today, based on our :timing_direction
  def self.days_today_is_away_from(this_date, timing_direction)
    days_1st_date_is_from_2nd(Date.current, this_date, timing_direction)
  end


  # Determine the number of days :a_date is _away_from_ :second_date.
  # The :timing_direction is whether we are calculating the number of days
  # _before_, _after_, or _on_ this day, starting from :a_date.
  #
  # @param a_date [Date] - the starting date
  # @param second_date [Date] - the date to compare to :a_date
  # @param timing_direction [Symbol] - which 'direction' (before, after, on) to compare to :a_date
  # @return [Integer] - the number of days separating the two dates, based on the :timing_direction
  def self.days_1st_date_is_from_2nd(a_date, second_date, timing_direction)

    day_num_to_check = 0 # default value

    # We use .to_date to ensure that we're comparing and working with Dates, not Times, etc.
    # If calling .to_date throws an exception, that's an exception that should be raised.

    if timing_direction == ConditionSchedule.timing_before
      # number of days that a_date is _before_ second_date
      day_num_to_check = second_date.to_date - a_date.to_date

    elsif timing_direction == ConditionSchedule.timing_after
      # number of days that a_date is _after_ second_date
      day_num_to_check = a_date.to_date - second_date.to_date
    end

    day_num_to_check.to_i
  end

end
