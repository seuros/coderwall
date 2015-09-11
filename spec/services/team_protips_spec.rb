require 'spec_helper'

RSpec.describe TeamProtips do

  let!(:team) do
    Fabricate.create(:team)
  end
  let(:service) { TeamProtips.new(team) }

  describe '#members_ids' do

    it 'returns nil' do
      expect(service.members_ids).to be_empty
    end
  end

  describe '#protips' do

    it 'returns nil' do
      expect(service.protips.count).to be_zero
    end
  end

  describe '#has_protips?' do

    it 'returns 0' do
      expect(service.has_protips?).to be false
    end
  end

end
