# frozen_string_literal: true


#--------------------------
#
# @class CompanyMetaInfoAdapter
#
# @desc Responsibility: Given a company, knows how to convert (adapt) the info
# into meta (tags) info for the company.  Use AppConfiguration values
# if value is blank for the Company
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file company_meta_info_adapter.rb
#
#--------------------------


class CompanyMetaInfoAdapter


  def initialize(company)
    @company = company
  end

  def title
    @company.name.blank? ? AdminOnly::AppConfiguration.config_to_use.site_meta_title : @company.name
  end


  def description
    @company.description.blank? ? AdminOnly::AppConfiguration.config_to_use.site_meta_description : InputSanitizer.sanitize_string(@company.description).squish
  end


  def keywords
    company_category_names =  @company.current_category_names.reject(&:blank?)
    if company_category_names.blank?
      AdminOnly::AppConfiguration.config_to_use.site_meta_keywords
    else
      company_category_names.join(', ')
    end
  end


  def og
    {
        title:       title,
        description: description
    }
  end

  # --------------------------------------------------------------------------

  private

  def clean_desc(desc)

  end

end

