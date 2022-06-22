require 'rails_helper'

RSpec.describe ShfApplicationsHelper, type: :helper do

  let(:category1) { build(:business_category, name: 'category1') }
  let(:category2) { build(:business_category, name: 'category2') }
  let(:category3) { build(:business_category, name: 'category3') }
  let(:app_3_cats) { create(:shf_application, num_categories: 0,
                             business_categories: [category1, category2, category3]) }

  let(:file_delivery_upload_now) { build(:file_delivery_upload_now) }
  let(:file_delivery_upload_later) { build(:file_delivery_upload_later) }
  let(:file_delivery_email) { build(:file_delivery_email) }
  let(:file_delivery_mail) { build(:file_delivery_mail) }
  let(:file_delivery_all_files_uploaded) { build(:file_delivery_files_uploaded) }

  before(:each) do
    allow(AdminOnly::FileDeliveryMethod).to receive(:order)
                                              .with('default_option DESC')
                                              .and_return([file_delivery_upload_now, file_delivery_upload_later, file_delivery_email, file_delivery_mail, file_delivery_all_files_uploaded])
  end


  describe '#states_selection_list gets the localized version of each state name each time it is requested' do
    let(:application) { build(:shf_application) }

    it 'returns the list in the default I18n locale' do
      select_list = helper.states_selection_list
      select_list.each do |each_option|
        expect(each_option[0]).to eq I18n.t("activerecord.attributes.shf_application.state/#{each_option[1]}")
      end
    end

    it 'correct locale if changed to :en from locale = :sv' do
      I18n.locale = :sv
      helper.states_selection_list

      I18n.locale = :en
      select_list = helper.states_selection_list
      select_list.each do |each_option|
        expect(each_option[0]).to eq I18n.t("activerecord.attributes.shf_application.state/#{each_option[1]}", locale: :en)
      end

    end
  end

  describe 'returns a list of reasons_for_waiting for the right locale' do

    before(:each) do
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv1', name_en: 'name_en1', description_sv: 'desc_sv1', description_en: 'desc_en1')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv2', name_en: 'name_en2', description_sv: 'desc_sv2', description_en: 'desc_en2')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv3', name_en: 'name_en3', description_sv: 'desc_sv3', description_en: 'desc_en3')
    end

    let(:reason1) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv1') }
    let(:reason2) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv2') }
    let(:reason3) { AdminOnly::MemberAppWaitingReason.find_by_name_sv('name_sv3') }

    describe '#reasons_for_waiting_names' do

      let(:expected_sv_names) { [[reason1.id, 'name_sv1'], [reason2.id, 'name_sv2'], [reason3.id, 'name_sv3']] }
      let(:expected_en_names) { [[reason1.id, 'name_en1'], [reason2.id, 'name_en2'], [reason3.id, 'name_en3']] }

      it 'calls name_sv if locale == sv' do
        name_list = helper.reasons_for_waiting_names(:sv)
        expect(name_list).to match expected_sv_names
      end

      it 'calls name_en if locale == en' do
        name_list = helper.reasons_for_waiting_names(:en)
        expect(name_list).to match expected_en_names
      end

      it 'calls default_name_method if there is no name method for that locale' do
        name_list = helper.reasons_for_waiting_names(:blorf)
        expect(name_list).to match expected_sv_names
      end

      it 'calls default_name_method if no locale is specified' do
        name_list = helper.reasons_for_waiting_names
        expect(name_list).to match expected_sv_names
      end


      it 'returns a list of [id, text]' do
        name_list = helper.reasons_for_waiting_names
        first_item = name_list.first
        expect(first_item.is_a?(Enumerable)).to be_truthy
        expect(first_item.first.is_a?(Numeric)).to be_truthy
        expect(first_item.last.is_a?(String)).to be_truthy
      end

    end


    describe '#reason_name_method' do

      it 'is :name_sv if locale == :sv' do
        expect(helper.reason_name_method(:sv)).to eq :name_sv
      end

      it 'is :name_en if locale == :en' do
        expect(helper.reason_name_method(:en)).to eq :name_en
      end

      it 'is default name method if there is no desc method for that locale' do
        expect(helper.reason_name_method(:blorf)).to eq AdminOnly::MemberAppWaitingReason.default_name_method
      end

      it 'is default name method if no locale is specified' do
        expect(helper.reason_name_method).to eq AdminOnly::MemberAppWaitingReason.default_name_method
      end

    end


    describe '#reason_description_method' do

      it 'is :desc_sv if locale == :sv' do
        expect(helper.reason_desc_method(:sv)).to eq :description_sv
      end

      it 'is :desc_en if locale == :en' do
        expect(helper.reason_desc_method(:en)).to eq :description_en
      end

      it 'is default desc method if there is no desc method for that locale' do
        expect(helper.reason_desc_method(:blorf)).to eq AdminOnly::MemberAppWaitingReason.default_description_method
      end

      it 'is default desc method if no locale is specified' do
        expect(helper.reason_desc_method).to eq AdminOnly::MemberAppWaitingReason.default_description_method
      end

    end


    describe '#reasons_for_waiting_descs' do

      let(:expected_sv_descs) { [[reason1.id, 'desc_sv1'], [reason2.id, 'desc_sv2'], [reason3.id, 'desc_sv3']] }
      let(:expected_en_descs) { [[reason1.id, 'desc_en1'], [reason2.id, 'desc_en2'], [reason3.id, 'desc_en3']] }

      it 'calls description_sv if locale == sv' do
        desc_list = helper.reasons_for_waiting_descs(:sv)
        expect(desc_list).to match expected_sv_descs
      end

      it 'calls description_en if locale == en' do
        desc_list = helper.reasons_for_waiting_descs(:en)
        expect(desc_list).to match expected_en_descs
      end

      it 'calls default_description_method if there is no desc method for that locale' do
        desc_list = helper.reasons_for_waiting_descs(:blorf)
        expect(desc_list).to match expected_sv_descs
      end

      it 'calls default_description_method if no locale is specified' do
        desc_list = helper.reasons_for_waiting_descs
        expect(desc_list).to match expected_sv_descs
      end


      it 'returns a list of [id, text]' do
        desc_list = helper.reasons_for_waiting_descs
        first_item = desc_list.first
        expect(first_item.is_a?(Enumerable)).to be_truthy
        expect(first_item.first.is_a?(Numeric)).to be_truthy
        expect(first_item.last.is_a?(String)).to be_truthy
      end

    end

  end

  describe "#reasons_collection appends an 'other' reason with name from the locale file" do

    it 'other reason is at the end of the list' do

      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv1', name_en: 'name_en1', description_sv: 'desc_sv1', description_en: 'desc_en1')
      FactoryBot.create(:member_app_waiting_reason, name_sv: 'name_sv2', name_en: 'name_en2', description_sv: 'desc_sv2', description_en: 'desc_en2')

      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.id).to eq(-999)

    end

    it "locale = default ( == sv); sets the name_sv" do
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.name_en).to be_nil
    end

    it 'locale = sv; sets the name_sv' do
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to eq 'other'
      expect(last_r.name_en).to be_nil
    end

    it 'locale = en; sets the name_en' do
      I18n.locale = :en
      last_r = helper.reasons_collection(-999, 'other').last
      expect(last_r.name_sv).to be_nil
      expect(last_r.name_en).to eq 'other'
    end

  end

  describe '#selected_reason_value' do

    let(:member_app) { build(:shf_application) }

    it '@other_reason_value if there is something in custom reason text' do
      member_app.custom_reason_text = 'something'
      expect(helper.selected_reason_value(member_app, -999)).to eq(-999)
    end


    describe 'member_app_waiting_reasons_id if there is not something in custom reason text' do

      it 'member_app_waiting_reasons_id if custom_reason_text == empty string ' do
        member_app.custom_reason_text = ''
        expect(helper.selected_reason_value(member_app, -999)).to eq member_app.member_app_waiting_reasons_id
      end

      it 'member_app_waiting_reasons_id if custom_reason_text == nil' do
        member_app.custom_reason_text = nil
        expect(helper.selected_reason_value(member_app, -999)).to eq member_app.member_app_waiting_reasons_id
      end
    end
  end

  describe '#list_app_categories' do
    it 'returns list of categories for an application' do
      expect(list_app_categories(app_3_cats)).to eq('category1, category2, category3')
    end
  end

  describe 'instructions_for_additional_category_qs' do
    it 'gets the links for all of the shf application categories' do
      expect(helper).to receive(:links_for_more_category_questions).with(app_3_cats.business_categories)
      helper.instructions_for_additional_category_qs(app_3_cats.business_categories, 'sv.shf_applications.create')
    end
  end

  describe 'links_for_more_category_questions' do
    it 'creates a link_for_more_category_questions for each business category' do
      expect(helper).to receive(:link_for_more_category_questions).exactly(3).times
      helper.links_for_more_category_questions([category1, category2, category3])
    end

    it 'default ul class is category-links' do
      expect(helper.links_for_more_category_questions([]).include?('<ul class=\'category-links\'')).to be_truthy
      expect(helper.links_for_more_category_questions([], ul_class: 'blorfo flurby').include?('<ul class=\'blorfo flurby\'')).to be_truthy
    end

    it 'default li class is category-link' do
      expect(helper.links_for_more_category_questions([category1]).include?('<li class=\'category-link\'')).to be_truthy
      expect(helper.links_for_more_category_questions([category1], li_class: 'flurbish blorfum').include?('<li class=\'flurbish blorfum\'')).to be_truthy
    end

    it 'creates a ul with each category as an li element' do
      expect(helper.links_for_more_category_questions([category2, category1])).to match(/<ul class='[^']+'(.*)<li(.*)<li(.*)<\/ul(.*)/)
    end

    it 'empty ul element if no business categories' do
      expect(helper.links_for_more_category_questions([]).include?('<li')).to be_falsey
    end
  end

  describe 'link_for_more_category_questions' do
    let(:result) { helper.link_for_more_category_questions(category1) }

    it 'default li class is category_link' do
      expect(helper.link_for_more_category_questions(category1).include?('<li class=\'category-link\'')).to be_truthy
      expect(helper.link_for_more_category_questions(category1, li_class: 'flurbish blorfum').include?('<li class=\'flurbish blorfum\'')).to be_truthy
    end

    it 'creates an li element with the category name and link and external link icon' do
      expect(result).to match(/<li class='[^']+'(.*)<\/li(.*)/)
    end

    it 'uses the external link icon' do
      # include the ShfIconsHelper so we can stub the methods
      described_class.module_eval do
        include ShfIconsHelper
      end

      allow(helper).to receive(:external_link_icon).and_return('external link icon')
      expect(helper.link_for_more_category_questions(category1).include?('external link icon')).to be_truthy
    end

    it 'link will open in a new window (target = _blank)' do
      expect(result.include?('target=\'_blank\'')).to be_truthy
    end
  end

  describe '#file_delivery_radio_buttons_collection' do

    let(:collection_sv)  do
      I18n.locale = :sv
      file_delivery_radio_buttons_collection
    end

    let(:collection_en)  do
      I18n.locale = :en
      file_delivery_radio_buttons_collection
    end


    it 'gets the options from AdminOnly::FileDeliveryMethod' do
      I18n.locale = :sv
      expect(file_delivery_radio_buttons_collection.count).to eq 5
    end

    it 'returns option descriptions - swedish' do
      I18n.locale = :sv
      expect(collection_sv).to contain_exactly(
        [file_delivery_upload_now.id, file_delivery_upload_now.description_sv],
        [file_delivery_upload_later.id, file_delivery_upload_later.description_sv],
        [file_delivery_email.id, file_delivery_email.description_sv + '*'],
        [file_delivery_mail.id, file_delivery_mail.description_sv + '**'],
        [file_delivery_all_files_uploaded.id, file_delivery_all_files_uploaded.description_sv]
      )
    end

    it 'returns option descriptions - english' do
      expect(collection_en).to contain_exactly(
        [file_delivery_upload_now.id, file_delivery_upload_now.description_en],
        [file_delivery_upload_later.id, file_delivery_upload_later.description_en],
        [file_delivery_email.id, file_delivery_email.description_en + '*'],
        [file_delivery_mail.id, file_delivery_mail.description_en + '**'],
        [file_delivery_all_files_uploaded.id, file_delivery_all_files_uploaded.description_en]
      )
    end

    it 'orders default option (upload) as first in list of buttons' do
      expect(collection_en.first).to eq [file_delivery_upload_now.id, file_delivery_upload_now.description_en]
    end
  end

  describe '#file_delivery_method_status' do

    it 'shows "none" (with no date) if no delivery method has been specified' do
      app = build(:shf_application, :legacy_application)
      fdm_msg = file_delivery_method_status(app)

      expect(fdm_msg).to match(/^#{I18n.t('shf_applications.show.files_delivery_method')}/)
      expect(fdm_msg).to match(/#{I18n.t('none_plur')}/)
      expect(fdm_msg).to_not match(/#{Date.current}/)
    end

    it 'shows chosen delivery method with date' do

      AdminOnly::FileDeliveryMethod::METHOD_NAMES.values.each do |fdm_name|

        app = create(:shf_application,
                     file_delivery_method: build("file_delivery_#{fdm_name}".to_sym))

        fdm = app.file_delivery_method
        fdm_msg = file_delivery_method_status(app)

        expect(fdm_msg).to match(/^#{I18n.t('shf_applications.show.files_delivery_method')}/)
        expect(fdm_msg).to match(/#{fdm.description_for_locale(I18n.locale)}/)
        expect(fdm_msg).to match(/#{Date.current}/)
      end
    end
  end


  describe 'business categories string for views' do

    let(:top_category) do
      cat = create(:business_category, name: 'Top Category')
      cat.children.create(name: 'cat1_subcat1')
      cat.children.create(name: 'cat1_subcat2')
      cat.children.create(name: 'cat1_subcat3')
      cat
    end

    let(:app) do
      app = build(:shf_application, num_categories: 0)
      app.save(validate: false)
      app.business_categories << top_category
      app.business_categories << top_category.children
      app
    end

    describe '#subcategories_list_in_parens' do

      it 'returns string of subcategories names in parens with "including:" preface' do
        subcategories = app.business_subcategories(top_category)
        expect(subcategories_list_in_parens(subcategories)).to eq " (#{t('including')}: cat1_subcat1, cat1_subcat2, cat1_subcat3)"
      end
    end

    describe '#business_categories_str' do

      it 'returns string with category and subcategory names' do
        expect(business_categories_str(app))
          .to eq "Top Category (#{t('including')}: cat1_subcat1, cat1_subcat2, cat1_subcat3)"
      end
    end

    # describe 'company_business_categories_str' do
    #   let(:co_with_3_current_cats) do
    #
    #   end
    #
    #   it 'builds a string with the current business categories' do
    #     pending
    #   end
    #
    #   it 'puts sub categories in a parenthesis' do
    #     expect(helper).to receive(:subcategories_list_in_parens)
    #                         .with('')
    #                         .and_return('(sub cat here)')
    #     helper.company_business_categories_str(app.companies.first)
    #   end
    # end
  end


  describe 'app_state_and_date' do
    let(:faux_app_aasm) { double('AASM::InstanceBase',
                                 state_object_for_name: double('AASM::Core::State', localized_name: 'accepted'),
                                 current_state: :accepted ) }
    let(:faux_app) { double('ShfApplication', :accepted? => false, when_approved: nil,
                            updated_at: (Date.current + 1.day),
                            aasm: faux_app_aasm)  }

    it 'is blank if the app is nil' do
      expect(helper.app_state_and_date(nil)).to be_blank
    end

    it "is the application state followed by the date (formatted with strftime('%F'))" do
      expect(helper.app_state_and_date(faux_app)).to match(/.* - \d\d\d\d-\d\d-\d\d/)
    end

    context 'app is accepted' do
      let(:approved_app) { faux_app }
      before(:each) { allow(approved_app).to receive(:accepted?).and_return(true) }

      it 'uses the when_approved date' do
        allow(approved_app).to receive(:when_approved).and_return(Date.current)
        expected_strftime = (Date.current).strftime('%F')
        expect(helper.app_state_and_date(approved_app)).to eq "accepted - #{expected_strftime}"
      end

      context 'when_approved is blank' do
        it 'uses the updated_at date' do
          allow(approved_app).to receive(:when_approved).and_return(nil)
          expected_strftime = (Date.current + 1.day).strftime('%F')
          expect(helper.app_state_and_date(approved_app)).to eq "accepted - #{expected_strftime}"
        end
      end
    end

    context 'app not accepted' do
      it 'uses the updated_at date' do
        expected_strftime = (Date.current + 1).strftime('%F')
        expect(helper.app_state_and_date(faux_app)).to match /.* - #{expected_strftime}/
      end
    end
  end
end
