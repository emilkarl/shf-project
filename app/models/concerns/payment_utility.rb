module PaymentUtility
  extend ActiveSupport::Concern

  included do

    def most_recent_payment(payment_type = self.class::THIS_PAYMENT_TYPE)
      payments.completed.send(payment_type).order(:created_at).last
    end

    def payment_start_date(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.start_date
    end

    def payment_expire_date(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.expire_date
    end

    def payment_notes(payment_type = self.class::THIS_PAYMENT_TYPE)
      most_recent_payment(payment_type)&.notes
    end
  end


  #   - FIXME how to store this date if/when the member is no longer a current member?
  #
  class_methods do

    # TODO should just pass in the entity.  the "id" is an implementation detail that callers should not care about.
    # TODO should just request the payment type as part of the method name.  Passing in the implementation of the payment type (e.g. Payment::PAYMENT_TYPE_BRANDING is an implementation detail that callers shouldn't care about)
    # Note:  Company cannot use this method.  It has a different business rule (i.e. it does not
    # use Today if no previous payment exists.)
    #
    # @param entity_id [Integer] - the id of the entity to get the next payment dates for
    # @param payment_type [Payment::PAYMENT_TYPE_MEMBER | Payment::PAYMENT_TYPE_BRANDING] - the specific type of the payment to look for
    #
    # @return [Array] - the start_date _and_ expire_date for the next payment
    def next_payment_dates(entity_id, payment_type = self::THIS_PAYMENT_TYPE)
      entity = find(entity_id)

      expire_date = entity.payment_expire_date(payment_type)

      if expire_date && expire_date.future?
        start_date = expire_date + 1.day
      else
        start_date = Time.zone.today  # can't use this to determine how many days OVERDUE the membership payment is!
      end

      expire_date = expire_date_for_start_date(start_date)

      [start_date, expire_date]
    end


    # Calculate the expiration date given a start date
    def expire_date_for_start_date(start_date)
      other_date_for_given_date(start_date, is_start_date: true)
    end


    # Helper method for cases where we have the expire date (ex: in tests)
    def start_date_for_expire_date(expire_date)
      other_date_for_given_date(expire_date, is_start_date: false)
    end


    # THIS IS THE KEY RULE ABOUT WHEN PAYMENTS EXPIRE
    #
    # Given a date, get the 'other' date: if we have a start date, get the expiration date.
    # If we have an expiration date, get the start date.
    #
    # The calculation is the same:  it is 1 year - 1 day "away" from the given date,
    # no matter if we are looking into the future (we have a start date
    #  and we and the expire date in the future)
    # or if we are looking backwards to the past (we have an expiration date
    #  and we want to know what the start date was).
    # The only difference is whether we are subtracting 1 year and adding 1 day,
    # or if we add one year and subtract 1 day; the difference is a multiplier of +/- 1.
    #
    # @param [Date] given_date - the date to calculate from
    #
    # @param [Boolean] is_start_date - is given_date the start date? (true by default)
    # @return [Date] - the resulting Date that was calculated
    def other_date_for_given_date(given_date, is_start_date: true)
      multiplier = is_start_date ? 1 : -1
      (given_date + (multiplier * 1.year) - (multiplier * 1.day) )
    end

  end
end
