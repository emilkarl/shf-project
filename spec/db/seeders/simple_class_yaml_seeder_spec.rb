require 'spec_helper'

# Use this so that we don't have to load Rails just to run this
require_relative File.join(__dir__, '../../../db/seeders/simple_class_yaml_seeder')

# -----------------------------------
# classes needed for stubs and mocks:
#
class FauxARKlass
  def self.all
    [new, new, new]
  end


  def serializable_hash
    'sh'
  end
end

class FauxSimpleSeederSubclass < Seeders::SimpleClassYamlSeeder
  SEEDED_CLASS = FauxARKlass
  YAML_FILENAME = 'faux-ar-klass-data.yml'
end
# -----------------------------------

RSpec.describe Seeders::SimpleClassYamlSeeder do

  def new_yml_tempfile
    Tempfile.new(['temp-yaml-out', '.yml'])
  end


  describe '.stripped_attribs removes attributes we do not want to write to the db, e.g. when creating a new object' do

    it 'removes :id, :created_at, and :updated_at' do
      expect(described_class.stripped_attribs({ id: 1, created_at: 2, updated_at: 3, blorf: 'flurb' })).to eq({ blorf: 'flurb' })
    end
  end

  describe '.create_object' do

    it 'calls create! with the seeded_class to create and save a new object to the database' do

      faux_ar_class = double("Faux ActiveRecord class")
      allow(faux_ar_class).to receive(:create!)
      allow(described_class).to receive(:seeded_class).and_return(faux_ar_class)

      expect(faux_ar_class).to receive(:create!).once.with({ name: 'this' })
      described_class.create_object({ id: 1, name: 'this' })
    end

    it 'subclasses must define SEEDED_CLASS' do
      expect { described_class.create_object({ id: 1, name: 'this' }) }.to raise_exception(NoMethodError, /undefined method .create!. for String:Class/)
    end
  end


  describe '.serialized_objects' do

    it 'calls serializable_hash for all <seeded_class> objects' do
      expect(FauxSimpleSeederSubclass.serialized_objects).to match_array(['sh', 'sh', 'sh'])
    end
  end


  describe '.seeded_class' do

    it 'default is the abstract class' do
      expect(described_class.seeded_class).to eq String
    end

    it 'returns the constant defined in a subclass' do
      expect(FauxSimpleSeederSubclass.seeded_class).to eq FauxARKlass
    end
  end

end
