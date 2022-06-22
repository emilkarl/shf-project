# frozen_string_literal: true

require 'observer'
require_relative File.join('..', 'services', 'address_exporter')

# ===============================================================================================
# @class Company
#
# @responsibility  A Company in the dog industry.
#
# @todo data consistency check:  every company should have at least 1 application
# @fixme Company should use Membership (CompanyMembership < Membership)
#
#
class Company < ApplicationRecord
  include IsMember
  include PaymentUtility
  include HasSwedishOrganization
  include Dinkurs::Errors
  include Observable

  before_destroy :destroy_checks

  validates_presence_of :company_number
  validates_uniqueness_of :company_number,
    message: I18n.t('activerecord.errors.models.company.attributes.company_number.taken')
  validates_length_of :company_number, is: 10
  validates :email, email: true

  validate :swedish_organisationsnummer

  validates :dinkurs_company_id, dinkurs_id: true

  after_initialize :add_observers
  before_save :sanitize_website, :sanitize_description

  has_many :company_applications
  has_many :shf_applications, through: :company_applications, dependent: :destroy

  has_many :users, through: :shf_applications
  has_many :events, dependent: :destroy

  has_many :memberships, as: :owner, dependent: :destroy, class_name: "CompanyMembership"

  has_many :payments, dependent: :nullify
  # ^^ need to retain h-branding payment(s) so that the total amount of $ paid to SHF is correct
  accepts_nested_attributes_for :payments

  # @todo this is a really ugly query. Why does it return multiples? (why is .distinct necessary?) Is there any way to clean it up?
  # This should only be used in testing when materialized views cannot be used.
  has_many :business_categories,
           -> { joins(shf_applications: [:user]).where(users: { membership_status: :current_member }).distinct },
           through: :shf_applications

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

  scope :has_name, -> { where.not(name:nil).where.not(name: '') }
  scope :blank_name, -> { where(name: '').or(Company.where(name: nil)) }

  scope :has_address, -> { joins(:addresses).where(id: [Address.pluck(:addressable_id)]).distinct }
  scope :lacking_address, -> { where.not(id: [Address.pluck(:addressable_id)]).distinct }

  # This excludes Companies that have no addresses:
  scope :addresses_have_region, -> { joins(:addresses).where(id: Address.has_region.pluck(:addressable_id)).distinct }

  # This includes Companies that have no addresses:
  scope :no_address_or_lacks_region, -> { where.not(id: Address.company_address.has_region.pluck(:addressable_id)) }

  # @fixme find all calls, replace with appropriate Membership... class method
  def self.next_membership_payment_dates(company_id)
    next_payment_dates(company_id, THIS_PAYMENT_TYPE)
  end


  after_update :clear_h_brand_jpg_cache,
               if: Proc.new { saved_change_to_name? }

  # -----------------------------------------------------------------------------------------------

  def self.clear_all_h_brand_jpg_caches
    all.each do |company|
      company.clear_h_brand_jpg_cache
    end
  end

  # Note: If the rules/definition for a 'complete' company changes, this scope
  # must be changed in addition to the code in CoInfoCompleteReqs
  #
  # A company has a name (not nil, not an empty string)
  #  AND
  # A company has an address
  #  AND
  #   that address has a region
  def self.information_complete
    has_name.addresses_have_region
  end

  singleton_class.alias_method :complete_information, :information_complete

  def self.not_complete
    blank_name.or(self.no_address_or_lacks_region)
  end

  singleton_class.alias_method :not_complete_information, :not_complete

  def self.branding_licensed
    # All companies (distinct) with at least one unexpired branding payment
    joins(:payments).merge(Payment.branding_fee.completed.unexpired).distinct
  end

  singleton_class.alias_method :branding_license_current, :branding_licensed

  def self.address_visible
    # Return ActiveRecord::Relation object for all companies (distinct) with at
    # least one visible address
    joins(:addresses).where.not('addresses.visibility = ?', 'none').distinct
  end

  # @todo yuck
  def self.with_members
    where(id: CompanyApplication.where(shf_application: [ShfApplication.where(user: User.current_member)]).pluck(:company_id))
  end

  # Criteria limiting visibility of companies to non-admin users
  # @todo rename this to current_with_current_members or in_good_standing_with_current_members (Company should not be responsible for knowing what is 'searchable' in the UI)
  # @fixme use materialized view instead CurrentCompany
  def self.searchable
    information_complete.with_members.branding_licensed
  end

  singleton_class.alias_method :current_with_current_members, :searchable
  singleton_class.alias_method :in_good_standing, :searchable

  # all companies at these addresses (array of Address)
  def self.at_addresses(addresses)
    joins(:addresses)
      .where(id: addresses.map(&:addressable_id))
  end

  def self.with_dinkurs_id
    where.not(dinkurs_company_id: [nil, '']).order(:id)
  end

  # The .sort_by_information_complete...   methods (=scopes) are used by the Ransack gem to
  #   do sorting. These methods are a way to do sorting using some value that is not an attribute or association
  #   @see https://github.com/activerecord-hackery/ransack#ransacks-sort_link-helper-creates-table-headers-that-are-sortable-links

  # This is a SQL case expression that returns a boolean named 'all_is_complete' based on whether the information for a company is complete.
  # This can be used in a select statement
  def self.is_complete_case_boolean
    "case when companies.name <> '' AND addresses.addressable_type = 'Company' AND addresses.region_id IS NOT NULL then TRUE else FALSE END".freeze
  end

  def self.sort_by_information_complete(sort_direction = :asc)
    joins(:addresses).order(Arel.sql("#{is_complete_case_boolean} #{sort_direction.to_s.upcase}"))
  end

  def self.sort_by_information_complete_asc
    sort_by_information_complete(:asc)
  end

  def self.sort_by_information_complete_desc
    sort_by_information_complete(:desc)
  end

  # ===============================================================================================

  # @fixme - change to Membership (is now just getting info from a Payment)
  alias_method :current_membership, :most_recent_payment

  # @todo rename this to current_with_current_members? or in_good_standing_with_current_members? (Company should not be responsible for knowing what is 'searchable' in the UI)
  # @fixme does not seem to be used
  def searchable?
    branding_license_current? && current_members.any?
  end

  alias_method :current_with_current_members?, :searchable?

  def add_observers
    add_observer DbViews::CurrentCompany, :company_status_changed
    add_observer DbViews::CompanyAndMember, :company_status_changed
    add_observer DbViews::CompanyAndCategory, :company_status_changed
  end

  # The Requirements class that has all the requirements for membership
  def requirements_for_membership
    Reqs::CompanyMembershipReqs
  end

  # The Requirements class that has all the requirements for renewal
  def requirements_for_renewal
    Reqs::CompanyRenewalReqs
  end

  def membership_changed
    changed # required so observers will be notified
    notify_observers(self, nil, nil)
  end

  def in_good_standing?
    information_complete? && branding_license_current?
  end

  def information_complete?
   Reqs::CoInfoCompleteReqs.satisfied? entity: self
  end

  # alias_method :information_complete?, :complete?

  def missing_region?
    addresses.map(&:region).include?(nil)
  end

  def missing_information
   Reqs::CoInfoCompleteReqs.missing_info entity: self
  end


  # @fixme can we use a Materialized view?
  # @return [ActiveRecord::Relation]
  def approved_applications_from_members
    shf_applications.accepted.joins(:user)
      .order('users.last_name').where('users.member = ?', true)
  end


  # @return all members in the company whose membership are current (paid, not expired)
  def current_members
    if Rails.env.test?
      users.where(membership_status: :current_member)
    else
      DbViews::CompanyAndMember.where(company_id: id).map(&:member)
    end
  end

  # @return [Array[User]] - all users in the company with accepted applications
  def accepted_applicants
    return [] if shf_applications.empty?

    shf_applications.select(&:accepted?).map(&:user)
  end

  def valid_key_and_fetch_dinkurs_events?(on_update: true)
    return true if on_update and !will_save_change_to_attribute?('dinkurs_company_id')

    result = false
    fetch_dinkurs_events
    return true
  rescue Dinkurs::Errors::InvalidKey
    errors.add(:dinkurs_company_id, :invalid_key)
    return result
  rescue Dinkurs::Errors::InvalidFormat
    errors.add(:dinkurs_company_id, :invalid_format)
    return result
  rescue URI::InvalidURIError
    errors.add(:dinkurs_company_id, :invalid_chars)
    return result
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

  # This depends on materialized views in the database, which are created based on the current DB time.
  # That cannot be easily stubbed during tests, so instead we have a conditional to see if we're doing tests.
  # Ugly.
  # But the alternative to this is to change ALL of the cucumber features to use dates based on an offset from Date.current (so that a materialzed view created based on the db CURRENT_DATE is always going to yield correct results)
  def current_categories(include_subcategories = false)
    categories = if Rails.env.test?
                   business_categories
                 else
                   DbViews::CompanyAndCategory.where(company_id: id).map(&:business_category)
                 end
    include_subcategories ? categories : categories.select { |category| category.ancestry.blank? }
  end

  # Ex with production data (2022-05-13):
  #  happyco = Company.where(company_number: '5590281829').first
  #  happyco.current_category_names
  #  # => ["Hundfysioterapeut", "Hundinstruktör"  , "Hundmassör", "Hundpsykolog"]
  #
  # @param [True, False] include_subcategories Should subcategories also be returned?
  # @return [Array<String>] a sorted list of the names of the categories for this company,
  #   where the categories are only those for the _current members_ of this company
  def current_category_names(include_subcategories = false)

    return current_categories(include_subcategories).map(&:name).uniq.sort unless include_subcategories

    names = []
    current_categories.each do |category|
      names << category.name
      names += category.children.order(:name).pluck(:name)
    end
    names
  end


  def categories_names(include_subcategories=false)
    # Fetch category names only for accepted applications from members
    cats = categories.roots
              .distinct
              .order(:name)
              .joins(shf_applications: :user)
              .where("users.member = ?", true)

    return cats.pluck(:name) unless include_subcategories

    names = []

    cats.each do |category|
      names << category.name
      names += category.children.order(:name).pluck(:name)
    end

    names
  end

  # @fixme only show if address visibility allows it
  def addresses_region_names
    addresses.joins(:region).select('regions.name').distinct.pluck('regions.name')
  end

  # @fixme only show if address visibility allows it
  def kommuns_names
    addresses.joins(:kommun).select('kommuns.name').distinct.pluck('kommuns.name')
  end

  # @fixme only show if address visibility allows it
  def cities_names
    addresses.select(:city).distinct.pluck(:city)
  end

  # @fixme replace with most_recent_membership_payment everywhere
  def most_recent_branding_payment
    most_recent_payment(THIS_PAYMENT_TYPE)
  end

  # @fixme find all calls, replace with appropriate Membership... class method (current.last_day)
  def branding_expire_date
    payment_expire_date(THIS_PAYMENT_TYPE)
  end

  # @todo this should not be the responsibility of the Company class. Need a MembershipManager class for this. (or common Membership class...)
  # @fixme change calls to either payment_notes or current_membership.notes
  def branding_payment_notes
    payment_notes(THIS_PAYMENT_TYPE)
  end

  # @fixme find all calls, replace with appropriate Membership... class method
  # @return [Boolean] - true only if there is a branding_expire_date and it is in the future (from today)
  def branding_license?
    # @todo can use payment_term_expired?(THIS_PAYMENT_TYPE)
    branding_expire_date&.future? == true # == true prevents this from ever returning nil
  end

  alias_method :branding_license_current?, :branding_license?

  # @todo this should not be the responsibility of the Company class. Need a MembershipManager class for this. (or common Membership class...)
  # @fixme change calls to either payment_notes or current_membership.notes
  def membership_payment_notes
    payment_notes(THIS_PAYMENT_TYPE)
  end

  # This is used to calculate when an H-Branding fee is due if there has not been any H-Branding fee paid yet
  # @todo this should go in a class responsible for knowing how to calculate when H-Branding fees are due (perhaps a subclass of PaymentUtility named something like CompanyPaymentsDueCalculator )
  # @fixme
  # This really is about the _payment_ and not about the date of the membership(s)
  # @return [nil, Time] if there are no current members
  #   else the earliest membership fee payment.created_at of all current members
  def earliest_current_member_fee_paid_time # @fixme  find usages
    current_members.empty? ? nil : current_members.map { |member| member.most_recent_payment(Payment.membership_payment_type)&.created_at }.sort.first
  end


  def next_membership_payment_dates
    self.class.next_membership_payment_dates(self.id)
  end


  def destroy_checks
    error_if_has_applications?
    record_deleted_payorinfo_in_payment_notes
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

  # @fixme - the company member(s) need to set this.  Picking the 'first' one is arbitrary and may be wrong
  def main_address

    return addresses.mail_address.includes(:region)[0] if addresses.mail_address.exists?

    return addresses.includes(:region).first if addresses.exists?

    new_address = Address.new(addressable: self)
    addresses << new_address
    new_address
  end

  def se_mailing_csv_str
    AddressExporter.se_mailing_csv_str(main_address)
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

  # @fixme use cache methods in IsMember. Will invalidate cache entries? task to recreate them all
  def cache_key(type)
    "company_#{id}_cache_#{type}"
  end

  # @fixme use cache methods in IsMember. Will invalidate cache entries? task to recreate them all
  def h_brand_jpg
    Rails.cache.read(cache_key('h_brand'))
  end

  # @fixme use cache methods in IsMember. Will invalidate cache entries? task to recreate them all
  def h_brand_jpg=(image)
    Rails.cache.write(cache_key('h_brand'), image)
  end

  # @fixme use cache methods in IsMember. Will invalidate cache entries? task to recreate them all
  def clear_h_brand_jpg_cache
    Rails.cache.delete(cache_key('h_brand'))
  end

  # ===============================================================================================

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
