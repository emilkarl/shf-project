require 'yaml'

#--------------------------
#
# @class ChecklistsSeeder
#
# @desc Responsibility: Seed checklists, their items and sub-checklists from a YAML file
#   Can also write hardcoded data out to the YAML file. (can write out and read in)
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-29
#
#--------------------------
class ChecklistsSeeder

  CHECKLISTS_YAML_SOURCE = File.join(__dir__, 'checklists.yml')

  MEMBERSHIP_LIST_NAME = 'Membership'
  APPLICATION_LIST_NAME = 'Application completion'
  REGISTER_LIST_NAME = 'Register as a user'
  ETHICAL_GUIDELINES_LIST_NAME = 'SHF Ethical Guidelines'


  CHECKLIST_ITEMS_KEY = 'ChecklistItems'
  SUBLISTS_KEY = 'Sublists'
  CHECKLISTS_KEY = 'Checklists'


  # We have to manually associate the checklist items with the checklists
  # and the sublists with their parent checklists (nested checklists).
  def self.seed
    checklists_info = read_yaml

    items = checklists_info[CHECKLIST_ITEMS_KEY.to_sym]
    sublists = checklists_info[SUBLISTS_KEY.to_sym]
    checklists = checklists_info[CHECKLISTS_KEY.to_sym]

    # First, create the checklists
    Checklist.create!(checklists)

    # Second, create the checklist items and associate them with their checklist:
    items.each do |item|
      checklist_owner = Checklist.find_by(name: item[:checklist_name])
      ChecklistItem.create!(name: item[:name],
                            description: item[:description],
                            order_in_list: item[:order_in_list],
                            checklist: checklist_owner)
    end

    # Finally, associate any sublists (nested checklists)
    sublists.each do |sublist|
      sub_checklist = Checklist.find_by(name: sublist[:sublist_name])
      parent_checklist = Checklist.find_by(name: sublist[:parent_checklist_name])
      sub_checklist.update(parent: parent_checklist)
    end

  end


  def self.read_yaml
    YAML.load(File.read(CHECKLISTS_YAML_SOURCE))
  end


# Write out Checklists and ChecklistItems to the source YAML file
  def self.write_yaml

    # ChecklistItems
    register_email = { name: 'email', description: 'Provide a valid email address for logging in.',
                       checklist_name: REGISTER_LIST_NAME,
                       order_in_list: 0 }
    register_password = { name: 'password', description: 'Create a password for logging in.',
                          checklist_name: REGISTER_LIST_NAME,
                          order_in_list: 1 }
    app_company_number = { name: 'Provide your org nummber', description: 'Provide the Org nummer (company number)',
                           checklist_name: APPLICATION_LIST_NAME,
                           order_in_list: 0 }
    app_business_cats = { name: 'Business categories', description: 'Check at least 1 business category',
                          checklist_name: APPLICATION_LIST_NAME,
                          order_in_list: 1 }
    app_documents = { name: 'Documents', description: 'Provide documents that show your certifications for the buisness categories',
                      checklist_name: APPLICATION_LIST_NAME,
                      order_in_list: 2 }
    membership_approved = { name: 'SHF has approved your application', description: 'SHF has reviwed and approved your application.',
                            checklist_name: MEMBERSHIP_LIST_NAME,
                            order_in_list: 2 }
    membership_pay = { name: 'Pay your membership fee', description: 'pay your membership fee',
                       checklist_name: MEMBERSHIP_LIST_NAME,
                       order_in_list: 3 }


    ethical_guideline_respect_dog = { name: 'Respect the Dog',
                                      description: '... something about this',
                                      checklist_name: ETHICAL_GUIDELINES_LIST_NAME,
                                      order_in_list: 0 }

    ethical_guideline_respect_owner = { name: 'Respect the Owner',
                                        description: '... something about this',
                                        checklist_name: ETHICAL_GUIDELINES_LIST_NAME,
                                        order_in_list: 1 }

    checklist_items = [
        register_email,
        register_password,
        app_company_number,
        app_business_cats,
        app_documents,
        membership_approved,
        membership_pay,
        ethical_guideline_respect_dog,
        ethical_guideline_respect_owner
    ]

    # Sublists (nested checklists)
    membership_register = { sublist_name: REGISTER_LIST_NAME,
                            parent_checklist_name: MEMBERSHIP_LIST_NAME,
                            order_in_list: 0 }
    membership_apply = { sublist_name: APPLICATION_LIST_NAME,
                         parent_checklist_name: MEMBERSHIP_LIST_NAME,
                         order_in_list: 1 }
    sublists = [
        membership_register,
        membership_apply
    ]


    # Checklists
    checklists = [
        { name: REGISTER_LIST_NAME, description: 'Provide information needed to register.' },
        { name: APPLICATION_LIST_NAME, description: 'Steps to complete an application for joining SHF' },
        { name: MEMBERSHIP_LIST_NAME, description: 'Steps to become a member' },
        { name: ETHICAL_GUIDELINES_LIST_NAME, description: 'SHF Member Ethical Guidelines' }
    ]

    all_checklist_info = { "#{CHECKLISTS_KEY}": checklists,
                           "#{CHECKLIST_ITEMS_KEY}": checklist_items,
                           "#{SUBLISTS_KEY}": sublists }

    File.open(CHECKLISTS_YAML_SOURCE, "w") { |file| file.write(all_checklist_info.to_yaml) }
  end
end
