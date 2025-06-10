require 'rails_helper'

RSpec.describe Distributor, type: :model do
  subject { build(:distributor) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:country_code) }
    it { should validate_length_of(:country_code).is_equal_to(2) }
  end

  describe 'associations' do
    it { should have_many(:tv_show_distributors).dependent(:destroy) }
    it { should have_many(:tv_shows).through(:tv_show_distributors) }
    it { should have_many(:release_dates).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_distributor) { create(:distributor, active: true) }
    let!(:inactive_distributor) { create(:distributor, active: false) }
    let!(:us_distributor) { create(:distributor, country_code: 'US') }
    let!(:uk_distributor) { create(:distributor, country_code: 'UK') }

    describe '.active' do
      it 'returns only active distributors' do
        expect(Distributor.active).to include(active_distributor)
        expect(Distributor.active).not_to include(inactive_distributor)
      end
    end

    describe '.by_country' do
      it 'returns distributors from specified country' do
        expect(Distributor.by_country('US')).to include(us_distributor)
        expect(Distributor.by_country('US')).not_to include(uk_distributor)
      end
    end
  end
end