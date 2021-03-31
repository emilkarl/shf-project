class CompanyApplication < ApplicationRecord
  belongs_to :company
  belongs_to :shf_application

  validates_presence_of :company, :shf_application

  validates_uniqueness_of :company_id, scope: :shf_application


  def self.accepted_apps_for(given_user)
    apps_for_user(given_user, state: 'accepted')
  end


  def self.rejected_apps_for(given_user)
    apps_for_user(given_user, state: 'rejected')
  end


  def self.apps_for_user(given_user, state: 'all')
    joins(shf_application: :user)
      .where(shf_application_id: [ShfApplication.send(state.to_sym).where(user: given_user)])
  end
end
