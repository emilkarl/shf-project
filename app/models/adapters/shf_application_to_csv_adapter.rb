#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class ShfApplicationToCsvAdapter
  #
  # @desc Responsibility: Takes a ShfApplication and creates (adapts it to) CSV
  # Because this needs to use route :_paths: (e.g. user_path and company_path),
  # this class includes the url_helper
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-03-16
  #
  # @file shf_application_to_csv_adapter.rb
  #
  #--------------------------
  class ShfApplicationToCsvAdapter < AbstractAdapter


    # Required so that the url for the payment page can be used
    include Rails.application.routes.url_helpers


    def target_class
      CsvRow
    end


    def set_target_attributes(target)
      app = @adaptee # save typing and make it clear we're adapting a ShfApplication
      target << app.contact_email
      target << app.user.email
      target << app.user.first_name
      target << app.user.last_name
      target << app.user.membership_number

      target << (app.user.date_membership_packet_sent.nil? ? '' : app.user.date_membership_packet_sent.to_date)

      target << I18n.t("shf_applications.state.#{app.state}")
      target << app.updated_at.strftime('%F')

      # business categories, all surrounded by double-quotes
      target <<  quote( "#{app.business_categories.map(&:name).join(', ')}" )

      # a company name may have commas, so surround with quotes so spreadsheets
      # recognize it as one string and not multiple comma-separated value
      last_co = app.companies.last
      target << (app.companies.empty? ? '' : quote("#{last_co.name}"))

      # membership is paid, else insert a link to the user (of the application)
      target << quote( paid_membership_or_link(app) )

      # membership expiry date, surrounded by quotes
      target << quote( (never_paid_if_blank(app.user.membership_expire_date)) )

      # H-brand is paid, else insert a link to the last company for the application
      target << quote( paid_h_brand_fee_or_link(app) )

      # H brand expiry date
      target << quote( h_brand_expiry(app) )


      # add the SE postal service mailing address info as a CSV string
      target << app.se_mailing_csv_str


      target
    end


    #====================================================================


    private


    def paid_membership_or_link(shf_app)
      paid_or_payment_link(shf_app.user.payments_current?, user_path(shf_app.user))
    end


    def paid_h_brand_fee_or_link(shf_app)
      shf_app.companies.empty? ? '-' : paid_or_payment_link(shf_app.companies.last&.branding_license?,
                                                            company_path(shf_app.companies.last.id))
    end


    def h_brand_expiry(shf_app)
      if shf_app.companies.empty?
        I18n.t('admin.export_ansokan_csv.never_paid')
      else
        (never_paid_if_blank(shf_app.companies.last.branding_expire_date))
      end
    end


    # t('Paid') if member fee is paid, otherwise make link to where to pay it
    def paid_or_payment_link(is_paid, payment_url)
      is_paid ? I18n.t('admin.export_ansokan_csv.paid') : I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: payment_url)
    end


    # return t('never paid') if arg isNil else the arg.to_s
    def never_paid_if_blank(arg)
      arg.blank? ? I18n.t('admin.export_ansokan_csv.never_paid') : arg.to_s
    end


    # surround the item with double quotes ("")
    def quote(item)
      "\"#{item}\""
    end

  end # ShfApplicationToCsvAdapter


end
