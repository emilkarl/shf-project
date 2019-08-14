#!/usr/bin/ruby



class ConditionResponderError < StandardError
end

class TimingNotValidError < ConditionResponderError
end

class ExpectedTimingsCannotBeEmptyError < ConditionResponderError
end


#--------------------------
#
# @class ConditionResponder
#
# @desc Responsibility: Take a condition and some configuration information
# and _responds_ (handles) the condition.
#
# This might mean looking thru members and sending them emails if
# some particular condition is met, for example.
#
# Although this class is nearly empty right now, it is here to clarify
# the overall design.
#
# TODO: ? rename to ConditionHandler - because it _handles_ conditions, it
# doesn't respond _to_ them or _with_ them (it doesn't send a Condition to anything.
#  It queries them and does it's own thing)
#
# @date   2018-12-13
#
# @file condition_responder.rb
#
#--------------------------
class ConditionResponder

  DEFAULT_SCHEDULE = ConditionResponderSchedule.
  DEFAULT_TIMING = TIMING_ON
  DEFAULT_CONFIG = {}


  # All subclasses must implement this class. This is how they respond to/
  #  handle a condition.
  #
  # @param condtion [Condition] - the Condition that must be responded do
  # @param log [ActivityLog] - the log file to write to
  def self.condition_response(_condition, _log)
    raise NoMethodError, "Subclass must define the #{__method__} method", caller
  end


  # Get the configuration from the condition
  # @param [Condition]
  # @return [Config] the condition.config,
  #                 or the DEFAULT_CONFIG if there is no condition
  def self.get_config(condition)
    condition.nil? ? DEFAULT_CONFIG : condition.config
  end


  # Get the timing from the condition
  # @param condition [Condition]
  # @return timing [ConditionResponseSchedule] - condition.timing if condition is nil,
  #                           return the DEFAULT_TIMING
  def self.get_timing(condition)
    condition.nil? ? DEFAULT_TIMING : condition.timing.to_sym
  end


  # keep this for backwards compatibility for now.  TODO: change usages to .validate_timing
  def self.confirm_correct_timing(timing, expected_timing, log)
    validate_timing(timing, [expected_timing], log)
  end


  # Validates that the timing is in the list of valid timings
  # for this ConditionResponder.
  # If it is not, it logs an error and raises and exception
  #
  # @param timing [ConditionResponderSchedule] - the timing to validate
  # @param expected_timings [Array] - list of valid timings
  # @param log [Log] - the log to record the error to
  #
  def self.validate_timing(timing, expected_timings=[], log)

    if expected_timings.empty?
      msg = "List of expected timings cannot be empty"
      log.record('error', msg)
      raise ExpectedTimingsCannotBeEmptyError, msg
    end

    valid_timings = expected_timings.is_a?(Enumerable) ? expected_timings : [expected_timings]

    unless valid_timings.include? timing
      msg = "Received timing :#{timing} which is not in list of expected timings: #{valid_timings}"
      log.record('error', msg)
      raise TimingNotValidError, msg
    end
  end


end # ConditionResponder
