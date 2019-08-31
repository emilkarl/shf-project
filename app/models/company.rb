require_relative File.join('..', 'services', 'address_exporter')


class Company < ApplicationRecord
  include PaymentUtility

  include HasSwedishOrganization

  include Dinkurs::Errors

  before_destroy :destroy_checks

  validates_presence_of :company_number
  validates_uniqueness_of :company_number,
    message: I18n.t('activerecord.errors.models.company.attributes.company_number.taken')
  validates_length_of :company_number, is: 10
  validates :email, email: true

  validate :swedish_organisationsnummer

  validates :dinkurs_company_id, dinkurs_id: true

  before_save :sanitize_website, :sanitize_description

  has_many :company_applications
  has_many :shf_applications, through: :company_applications, dependent: :destroy

  has_many :users, through: :shf_applications
  has_many :events, dependent: :destroy

  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :payments

  has_many :business_categories, through: :shf_applications

  has_many :addresses, as: :addressable, dependent: :destroy,
           inverse_of: :addressable
  # ^^ we add the "inverse_of" option because we are validating the presence of
  # a company parent instance when we save the associated address(es).
  # See section "Validating the presence of a parent model" here:
  # https://apidock.com/rails/ActiveRecord/NestedAttributes/
  #     ClassMethods#971-Validating-presence-of-parent-in-child

  has_many :pictures, class_name: 'Ckeditor::Picture', dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true
  alias_method :categories, :business_categories
  delegate :visible, to: :addresses, prefix: true


  THIS_PAYMENT_TYPE = Payment::PAYMENT_TYPE_BRANDING



  def self.next_branding_payment_dates(company_id)
    next_payment_dates(company_id, THIS_PAYMENT_TYPE)
  end


  # Note: If the rules/definition for a 'complete' company change, this scope
  # must be changed in addition to the code in RequirementsForCoInfoComplete
  #
  # All addresses for a company are complete AND the name is not blank
  # must qualify name with 'companies' because there are other tables that use 'name' and if
  # this scope is combined with a clause for a different table that also uses 'name',
  # SQL won't know which table to get 'name' from
  #  name could be NULL or it could be an empty string
  def self.complete
    where.not('companies.name' => '',
              id: Address.lacking_region.pluck(:addressable_id))
  end


  def self.branding_licensed
    # All companies (distinct) with at least one unexpired branding payment
    joins(:payments).merge(Payment.branding_fee.completed.unexpired).distinct
  end


  def self.address_visible
    # Return ActiveRecord::Relation object for all companies (distinct) with at
    # least one visible address
    joins(:addresses).where.not('addresses.visibility = ?', 'none').distinct
  end

  def self.with_members
    joins(:shf_applications)
        .where('shf_applications.state = ?', :accepted)
        .joins(:users).where('users.member = ?', true).distinct
  end


  def self.searchable
    # Criteria limiting visibility of companies to non-admin users
    complete.with_members.branding_licensed
  end


  # all companies at these addresses (array of Address)
  def self.at_addresses(addresses)
    joins(:addresses)
        .where(id: addresses.map(&:addressable_id) )
  end


  def self.with_dinkurs_id
    where.not(dinkurs_company_id: [nil, '']).order(:id)
  end


  def complete?
    RequirementsForCoInfoComplete.requirements_met? company: self
  end


  def missing_region?
    addresses.map(&:region).include?(nil)
  end


  def approved_applications_from_members
    # Returns ActiveRecord Relation
    shf_applications.accepted.includes(:user)
      .order('users.last_name').where('users.member = ?', true)
  end


  def validate_key_and_fetch_dinkurs_events(on_update: true)
    return true if on_update and !will_save_change_to_attribute?('dinkurs_company_id')
    fetch_dinkurs_events
    true
  rescue Dinkurs::Errors::InvalidKey
    errors.add(:dinkurs_company_id, :invalid)
    return false
  rescue URI::InvalidURIError
    errors.add(:dinkurs_company_id, :invalid_chars)
    return false
  end


  def fetch_dinkurs_events
    events.clear
    return if dinkurs_company_id.blank?
    Dinkurs::EventsCreator.new(self, events_start_date).call
  end


  def events_start_date
    # Fetch events that start on or after this date
    1.day.ago.to_date
  end


  def any_visible_addresses?
    addresses_visible.any?
  end


  def categories_names
    categories.select(:name).distinct.order(:name).pluck(:name)
  end


  def addresses_region_names
    addresses.joins(:region).select('regions.name').distinct.pluck('regions.name')
  end


  def kommuns_names
    addresses.joins(:kommun).select('kommuns.name').distinct.pluck('kommuns.name')
  end

  def cities_names
    addresses.select(:city).distinct.pluck(:city)
  end


  def most_recent_branding_payment
    most_recent_payment(THIS_PAYMENT_TYPE)
  end


  def branding_expire_date
    payment_expire_date(THIS_PAYMENT_TYPE)
  end


  def branding_payment_notes
    payment_notes(THIS_PAYMENT_TYPE)
  end


  # @return [Boolean] - true only if there is a branding_expire_date and it is in the future (from today)
  def branding_license?
    # TODO can use term_expired?(THIS_PAYMENT_TYPE)
    branding_expire_date&.future? == true # == true prevents this from ever returning nil
  end


  # This is used to calculate when an H-Branding fee is due if there has not been any H-Branding fee paid yet
  # TODO: this should go in a class responsible for knowing how to calculate when H-Branding fees are due (perhaps a subclass of PaymentUtility named something like CompanyPaymentsDueCalculator )
  #
  # @return nil if there are no current members else the earliest membership_start_date of all current members
  def earliest_current_member_fee_paid
    current_members.empty? ? nil : current_members.map(&:membership_start_date).sort.first
  end


  def destroy_checks

    error_if_has_applications?

  end


  # do not delete a Company if it has ShfApplications that are accepted
  def error_if_has_applications?
    shf_applications.reload

    if shf_applications.where.not(state: 'being_destroyed').any?
      errors.add(:base, 'activerecord.errors.models.company.attributes.company_has_active_memberships')
      # Rails 5: must throw
      throw(:abort)
    end

    true

  end


  # @return all members in the company whose membership are current (paid, not expired)
  def current_members
    users.select(&:membership_current?)
  end


  def main_address

    return addresses.mail_address.includes(:region)[0] if addresses.mail_address.exists?

    return addresses.includes(:region).first if addresses.exists?

    new_address = Address.new(addressable: self)
    addresses << new_address
    new_address
  end


  def se_mailing_csv_str
      AddressExporter.se_mailing_csv_str( main_address )
  end


  def get_short_h_brand_url(url)
    found = self.short_h_brand_url
    return found if found
    short_url = ShortenUrl.short(url)
    if short_url
      self.update_attribute(:short_h_brand_url, short_url)
      short_url
    else
      url
    end
  end


  # ========================================================================


  private


  # clean the value for the website so we don't store potential XSS
  #  strip out anything that might start with 'script' (like 'javascript')
  #  to help prevent XSS attacks
  def sanitize_website
    self.website = InputSanitizer.sanitize_url(website)
  end


  def sanitize_description
    self.description = InputSanitizer.sanitize_html(description)
  end

end
