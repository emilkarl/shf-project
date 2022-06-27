# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class AbstractRequirements
  #
  # @desc Responsibility: Abstract class for checking to see if all requirements
  #       have been met for some class. It verifies that the arguments include _entity:_ and optionally _date:_
  #       It responds to '.satisfied?' with true (all requirements are met/satisified)
  #       or false (they are not met/satisfied)
  #
  #       Other classes/objects should call .satisfied?  and _not_ .requirements_met?
  #         because .satisfied? will perform checks (arguments) that will catch problems.
  #
  #       Each subclass MUST define the following method:
  #        'self.requirements_met?(_args)'  does the actual checking to see
  #           if the requirements have been satisifed
  #
  #
  #  This is implemented as a Class instead of a Singleton, but either approach is valid.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/23/17
  # @file abstract_requirements.rb

  #--------------------------

  class AbstractRequirements

    # this is the public interface for all Requirements classes:
    def self.satisfied?(args = {})
      has_expected_arguments?(args) && requirements_met?(args)
    end

    # Check for expected arguments.
    # Subclasses can call this and then check for their own additional arguments if needed.
    #
    # @param [Array] args
    #    entity: <value> (ex a User or a Company)
    #    optional argument  date: <some date>
    def self.has_expected_arguments?(args)
      has_expected_keys = args_have_keys?(args, [:entity])
      return false unless has_expected_keys

      raise ArgumentError, "entity is nil.  args = #{args}" if args.fetch(:entity).nil?

      has_expected_keys
    end

    # -------------------------------------------------------------------------
    # The following methods would be private if Ruby had private class methods
    #   Note: these could be private instance methods if this class were implemented as a Singleton

    # Don't use Rails (ActiveSupport) methods because we want to be able to run tests for this without having to load Rails.
    # @return [Boolean] - do the arguments have all of the required keys :keys ?
    def self.args_have_keys?(args, expected_keys)

      return true if expected_keys.nil? || expected_keys.empty?

      return false if expected_keys.size > 0 && (!args || args.empty?)

      args.extend ::Hashie::Extensions::DeepFind # ability to find a key in a nested Hash
      expected_keys.inject(true) { |have_key, key| have_key && !args.deep_find(key).nil? }
    end

    # Subclasses MUST override this
    def self.requirements_met?(_args)
      raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
    end
  end
end
