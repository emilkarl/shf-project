# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @class RequirementsForHBrandingFeeWillExpire
  #
  # @desc Responsibility: Knows when an H-Branding Fee WILL BE expiring for a company
  # (= the requirements are met). This is about the upcoming expiration date
  # for the H-Branding license.
  #
  #       This is a very simple class because the requirements are currently very simple.
  #       The importance is that
  #        it is the only place that code needs to be touched if the rules for
  #        when an H-Branding fee is due are changed.
  #
  #  Only 1 is needed for the system.
  #
  # @fixme how is this any different from checking that a company is in good standing / current?
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2019-03-05
  # @file requirements_for_h_branding_fee_will_expire.rb
  #
  #--------------------------

  class RequirementsForHBrandingFeeWillExpire < AbstractReqsForMember

    # The _prerequisites_ are met for for an H-Branding fee to expire in the future
    # if there are current members in the company
    #  AND the branding_license IS current
    # @fixme this means the company is in good standing (or the company is a current_member). Use that method instead?
    def self.requirements_met?(args)
      company = args[:entity]
      company.current_members.any? && company.branding_license?
    end

  end
end
