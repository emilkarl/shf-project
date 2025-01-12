# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class CoInfoCompleteReqs
  #
  # @desc Responsibility: Knows when the a company has all required information
  #       a.k.a. is "complete" (= the requirements are met)
  #
  #       This is a very simple class because the requirements are currently very simple.
  #
  #       If the rules/definition for a 'complete' company change, this class
  #       must be changed _and_ the Company.complete scope must be changed.
  #
  #  Only 1 is needed for the system.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2019-02-06
  # @file co_info_complete_reqs.rb
  #
  #--------------------------

  class CoInfoCompleteReqs < AbstractRequirements

    # the company has a name and every address for it has a Region
    def self.requirements_met?(args)
      company = args[:entity]

      !(company.name.blank? || company.missing_region?)
    end

    # This could be generalized if needed; it is not DRY because it repeats code in requirements_met?
    #   Because we're just checking 2 specific pieces of information,
    #   this is simple and explicit.
    def self.missing_info(args)
      raise(ArgumentError, 'arguments do not include the expected keys') unless has_expected_arguments?(args)
      company = args[:entity]

      missing_errors = []
      missing_errors << I18n.t('activerecord.attributes.company.name') if company.name.blank?
      missing_errors << I18n.t('activerecord.attributes.address.region') if company.missing_region?
      missing_errors
    end
  end
end
