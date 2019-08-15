# class:          Condition
#
# Responsibility: Provides the information needed so that a specific
#                 class can be instantiated and :condition_response
#                 can run on those instances.
#
#                 This class is  _descriptive._  (= the configration pattern)
#
#                 Ex:  A nightly rake/rails task will go thru all of the
#                 Condition record in the db and, using the information in each,
#                 instantiate the class in _class_name_.
#                 The task will send each such class the :condition_response method,
#                 passing it the condition to respond to.
#
#                 Each instance will then do 'whatever needs to be done' when
#                 it is sent :condition_response with the condtion.
#                 Ex: this will send out emails to all users that are past due
#                 with their Membership fee, etc.
#
#
# Attributes: These are all essentially *class variables* as they apply
#   to every instance of a class.
#
#   class_name - (String) the name of the class to instantiate
#   timing - (ConditionSchedule) this can be mostly descriptive so that the code
#             reads much more naturally.  Some classes may need to use
#             this when running :process_condition.
#             NOTE: this is serialized, so the value can be specified as a symbol.
#   config - (Hash) whatever configuration information is required for a
#             particular ConditionResponse class
#
#  @author:  Patrick Bolger
#
#
class Condition < ApplicationRecord
  serialize :config
  serialize :timing


  validates :class_name, presence: true
  # Note that we cannot validate the presence of an empty Hash because serialize persists is as NULL

  validate do
    errors.add(:timing, :invalid) unless timing.blank? || timing.is_a?(ConditionSchedule)
    errors.add(:config, :invalid) unless config.is_a?(Hash)
  end


  after_initialize :init_config

  DEFAULT_CONFIG = {}


  # ------------------------------------------

  private

  # config is initialized to an empty Hash
  def init_config
    update(config: DEFAULT_CONFIG) if config.nil?
  end

end
