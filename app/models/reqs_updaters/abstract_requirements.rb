#--------------------------
#
# @class AbstractRequirements
#
# @desc Responsibility: Abstract class for checking to see if all requirements
#       have been met for some class.
#       It responds to '.satisfied?' with true (all requirements are met/satisified)
#       or false (they are not met/satisfied)
#
#
#       Each subclass MUST define the following methods:
#
#        'self.has_expected_arguments?(args)' verifies that the all the arguments (a Hash)
#           expected are provided so that requirements can be checked
#           Must return true or false (*not* nil) per the convention of a method that ends with "?"
#
#        'self.requirements_met?(_args)'  does the actual checking to see
#           if the requirements have been satisifed
#
#
#  This is implemented as a Class instead of a Singleton, but either approach is valid.
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/23/17
# @file abstract_requirements.rb
#
#--------------------------


class AbstractRequirements

  # this is the public interface for all Requirements classes:
  def self.satisfied?(args = {})
    has_expected_arguments?(args) && requirements_met?(args)
  end


  # -------------------------------------------------------------------------
  # The following methods would be private if Ruby had private class methods
  #   Note: these could be private instance methods if this class were implemented as a Singleton

  # @return [Boolean] - do the arguments have all of the required keys :keys ?
  def self.args_have_keys?(args, keys)

    return true if keys.nil? || keys.empty?

    return false if keys.size > 0 && (!args || args.empty?)

    args.extend Hashie::Extensions::DeepFind  # ability to find a key in a nested Hash

    keys.inject(true) { |have_key, key| have_key && !args.deep_find(key).nil?}
  end


  # Subclasses MUST override this
  def self.has_expected_arguments?(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end


  # Subclasses MUST override this
  def self.requirements_met?(_args)
    raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
  end

end # AbstractRequirements
