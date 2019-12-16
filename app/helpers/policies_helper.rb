module PoliciesHelper
  # FIXME: this seems to duplicate behavior in User
  def is_in_company?(company)
    user.in_company_numbered?(company.company_number)
  end
end
