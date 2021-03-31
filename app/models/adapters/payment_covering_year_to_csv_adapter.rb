#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class PaymentCoveringYearToCsvAdapter
  #
  # @desc Responsibility: Takes a Payment and creates (adapts it to) CSV including
  #  information about what part (percent) of the year it covers.
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-02-20
  #
  #
  #--------------------------
  class PaymentCoveringYearToCsvAdapter < PaymentToCsvAdapter


    def set_target_attributes(target)
      payment_covering_year = @adaptee
      payment = @adaptee.payment

      target << payment.id

      target.append_items user_info(payment)

      target.append_items payment_type_info(payment)

      target.append_items payment_amount(payment)

      target.append_items term_dates(payment)

      target << payment_covering_year.total_number_of_days_paid
      target << payment_covering_year.sek_per_day

      target << payment_covering_year.num_days_of_year_covered
      target << payment_covering_year.days_paid_for_year

      target << quote(payment.created_at.strftime('%F'))

      target.append_items company_info(payment)

      target.append_items hips_info(payment)

      target << quote(payment.notes)

      target
    end


    # TODO - DRY with superclass
    #
    # @return [Array<String] - a list of the header strings
    #
    def self.headers(year)
      ["#{I18n.t('activerecord.models.payment.one')} db id",
       I18n.t('name'),
       'E-post',
       I18n.t('activerecord.attributes.user.membership_number'),
       I18n.t('payment_type', scope: I18N_PAYMENT_ATTRIBS),
       'total payment',

       'Term ' + I18n.t('start_date', scope: I18N_PAYMENT_ATTRIBS),
       'Term ' + I18n.t('expire_date', scope: I18N_PAYMENT_ATTRIBS),
       'total # days paid',

       'SEK / dag',
       "# days #{year} paid for",
       "SEK paid in #{year}",

       'Pay. date',
       'Org.',
       I18n.t('org_nr'),
       I18n.t('status', scope: I18N_PAYMENT_ATTRIBS),
       'HIPS id',
       I18n.t('notes', scope: I18N_PAYMENT_ATTRIBS)
      ]
    end
  end
end
