# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class CoInfoNotCompleteReqs
  #
  # @desc Responsibility: Knows when the required information for a company
  #       is _not_ complete
  #
  #       This is a very simple class because the requirements are currently very simple.
  #       The importance is that
  #        it is the only place that code needs to be touched if the rules for
  #        this are changed.
  #
  #  Only 1 is needed for the system.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2019-02-06
  # @file co_info_not_complete_reqs.rb
  #
  #--------------------------

  class CoInfoNotCompleteReqs < AbstractOppositeRequirements

    def self.opposite_class
      Reqs::CoInfoCompleteReqs
    end

  end


  # CoInfoNotCompleteReqs
end
