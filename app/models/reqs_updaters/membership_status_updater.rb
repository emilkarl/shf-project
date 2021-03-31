# Log messages:
#
LOGMSG_APP_UPDATED = 'SHF_application updated'
LOGMSG_APP_UPDATED_CHECKREASON = 'Membership checked because this shf_application was updated: '
LOGMSG_PAYMENT_MADE = 'Payment made'
LOGMSG_PAYMENT_MADE_CHECKREASON = 'Finished checking membership status because this payment was made: '
LOGMSG_APP_UPDATED = 'ShfApplication updated'
LOGMSG_USER_UPDATED = 'User updated'
LOGMSG_USER_UPDATED_CHECKREASON = 'User updated: '

LOGMSG_MEMBERSHIP_GRANTED = 'Membership granted'
LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed'
LOGMSG_MEMBERSHIP_REVOKED = 'Membership revoked'


#--------------------------
#
# @class MembershipStatusUpdater
#
# @desc Responsibility:  Keep membership status up-to-date based the current business rules
#    and requirements.
#  - gets notifications from events in the system and does what is needed with them to
#    update the status of memberships for people in the system
#
#    This is a Singleton.  Only 1 is needed for the system.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   12/21/17
# @file membership_status_updater.rb
#
#
# The Observer pattern is used to send notifications (methods) when something
# 'interesting' has changed.  When the MembershipStatusUpdater receives one of these
# notifications, it checks the membership to see if it needs to be changed (updated
# or revoked).  It does this via the :check_requirements_and_act({ user: user })
# method.  (This method is the public interface and main method for all
# Updater classes.)
#
# This check is logged with the ActivityLogger so that anything that happens is
# logged.
#
#
#   MembershipStatusUpdater has the responsibility of checking to see if the membership
#   should be updated or revoked based on the current business rules.
#   Thus all of the business rules can be in just _one place_ (DRY).
#   Only 1 class has the responsibility for enforcing them.  No other classes have to care about them.
#
#   Satisfies the "Open/Closed" principle in SOLID:  putting the business logic
#   into 1 Observer class keeps it open to extension changes (just this class)
#   but closed to having to modify lots of code when the requirements change
#
#   Business logic for when a Membership is granted or revoked is encapsulated into 1 class
#   that others are _not_ coupled to.
#   Ditto with logic about Membership terms - whether they have expired or not,
#   how the ending (expire) date is changed, etc.
#
#--------------------------

class MembershipStatusUpdater
  include Singleton


  SEND_EMAIL_DEFAULT = true


  # -----------------------------------------------------------------------------------
  # Notifications received from observed classes:
  # - - -
  # Could set up some more generalized meta-code to get information from notifications sent,
  # but this is simple to maintain because it is explicit.
  #

  def shf_application_updated(shf_app)
    update_membership_status(shf_app.user, shf_app, logmsg_app_updated)
  end


  def payment_made(payment)
    update_membership_status(payment.user, payment, logmsg_payment_made)
  end


  def user_updated(user)
    update_membership_status(user, user, logmsg_user_updated)
  end


  # FIXME should checklist_completed...  be added?
  # end of Notifications received from observed classes
  # -----------------------------------------------------------------------------------


  #  This is the main method for checking and changing the membership status.
  #     TODO: for a given date
  #
  def update_membership_status(user, notification_sender = nil, reason_update_happened = nil)
    today = Date.current

    ActivityLogger.open(log_filename, self.class.to_s, "#{__method__}", false) do |log|
      log.info("update_membership_status for #{user.inspect}")
      log.info("#{reason_update_happened}: #{notification_sender.inspect}") unless notification_sender.blank?

      # FIXME - refactor/DRY so we don't have to call  log.record(:info, user.membership_changed_info) every time.
      #   yield?  send the log to User? (no!)
      if user.not_a_member? || user.former_member?
        if RequirementsForMembership.satisfied?(user: user)
          user.start_membership!(date: today)
          log.info( user.membership_changed_info)
        end

      elsif user.current_member?

        if user.membership_expired_in_grace_period?(today)
          user.start_grace_period!
          log.info( user.membership_changed_info)

        elsif user.membership_past_grace_period_end?(today)
          # This shouldn't happen. But just in case the membership status has not been updated for
          # a while and so hasn't transitioned to in_grace_period, we'll do it manually now and then
          # go on and transition to a former member
          user.start_grace_period!
          log.info( user.membership_changed_info)
          user.make_former_member!
          log.info( user.membership_changed_info)
        end

        if RequirementsForRenewal.satisfied?(user: user)
          user.renew!(date: today)
          log.info( user.membership_changed_info)
        end


      elsif user.in_grace_period?

        if user.membership_past_grace_period_end?(today)
          user.make_former_member!
          log.info( user.membership_changed_info)
        else
          if RequirementsForRenewal.satisfied?(user: user)
            user.renew!(date: today)
            log.info( user.membership_changed_info)
          end
        end
      end

    end
  end


  def send_email
    SEND_EMAIL_DEFAULT
  end


  def logmsg_app_updated
    LOGMSG_APP_UPDATED
  end

  def logmsg_user_updated
    LOGMSG_USER_UPDATED
  end


  def logmsg_payment_made
    LOGMSG_PAYMENT_MADE
  end

  # -----------------------------------------------------------------------------------------------

  private


  def log_filename
    LogfileNamer.name_for(self.class.name)
    # File.join(Rails.configuration.paths['log'].absolute_current, "#{Rails.env}_#{self.class.name}.log")
  end
end
