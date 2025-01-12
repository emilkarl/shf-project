# frozen_string_literal: true

require 'rails_helper'

module Reqs
  RSpec.describe CoInfoNotCompleteReqs do
    let(:subject) { Reqs::CoInfoNotCompleteReqs }

    describe '.requirements_met?' do

      context 'company name is not blank and address region not nil' do

        it 'one address: true' do
          new_co = create(:company, region: create(:region))
          expect(subject.requirements_met?({ entity: new_co })).to be_falsey
        end

        it '3 addresses (all with Regions): true' do
          new_co = create(:company, num_addresses: 3, region: create(:region))
          expect(subject.requirements_met?({ entity: new_co })).to be_falsey
        end

      end

      it 'company name is blank: false' do
        new_co = create(:company, region: create(:region))
        new_co.name = ''
        expect(subject.requirements_met?({ entity: new_co })).to be_truthy
      end

      it 'one of the addresses has a region that is nil: false' do
        new_co = create(:company, num_addresses: 3, region: create(:region))
        new_co.addresses.last.region = nil
        expect(subject.requirements_met?({ entity: new_co })).to be_truthy
      end

    end
  end
end
