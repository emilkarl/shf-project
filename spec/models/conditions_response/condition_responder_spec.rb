require 'rails_helper'

require 'shared_context/activity_logger'


RSpec.describe ConditionResponder, type: :model do

  include_context 'create logger'


  describe '.condition_response' do

    it 'raises NoMethodError (must be defined by subclasses)' do

      condition    = Condition.create(class_name: 'MembershipExpireAlert',
                                      timing:     'before',
                                      config:     { days: [60, 30, 14, 2] })

      expect { described_class.condition_response(condition, log) }.to raise_exception NoMethodError
    end

  end


  it 'DEFAULT_TIMING is :on' do
    expect(ConditionResponder::DEFAULT_TIMING).to eq :on
  end

  describe '.get_timing' do

    it 'always returns a symbol' do
      expect(ConditionResponder.get_timing(create(:condition, timing: :blorf))).to eq(:blorf)
    end

    context 'condition is nil' do
      it 'returns the DEFAULT TIMING' do
        expect(ConditionResponder.get_timing(nil)).to eq ConditionResponder::DEFAULT_TIMING
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_timing(create(:condition, timing: :flurb))).to eq(:flurb)
      end
    end

  end


  it 'DEFAULT_CONFIG is an empty Hash' do
    default_c = ConditionResponder::DEFAULT_CONFIG
    expect(default_c).to be_a Hash
    expect(default_c).to be_empty
  end

  describe '.get_config' do

    context 'condition is nil' do
      it 'returns the DEFAULT_CONFIG TIMING' do
        expect(ConditionResponder.get_config(nil)).to eq ConditionResponder::DEFAULT_CONFIG
      end
    end

    context 'condition is not nil' do
      it 'returns the timing from the condition if condition is not nil' do
        expect(ConditionResponder.get_config(create(:condition, config: {mertz: 732} ))).to eq({mertz: 732})
      end
    end

  end

  describe '.confirm_correct_timing' do

    let(:condition) { build(:condition, :every_day) }
    let(:timing) { ConditionResponder.get_timing(condition) }

    it 'does not raise exception if received timing == expected' do
      expect(described_class).to receive(:validate_timing).with(:every_day, [:every_day], log)

      expect { ConditionResponder.confirm_correct_timing(:every_day, :every_day, log) }
        .not_to raise_error
    end

    it 'raises exception if received timing != expected' do
      expect(described_class).to receive(:validate_timing).with(:not_every_day, [:every_day], log)
      ConditionResponder.confirm_correct_timing(:not_every_day, :every_day, log)
    end

  end


end
