require 'rails_helper'

RSpec.describe Distributor, type: :model do
  describe 'associations' do
    it { should have_many(:tv_show_distributors).dependent(:destroy) }
    it { should have_many(:tv_shows).through(:tv_show_distributors) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    
    it 'validates website_url format' do
      distributor = build(:distributor, website_url: 'invalid-url')
      expect(distributor).not_to be_valid
      expect(distributor.errors[:website_url]).to be_present
    end

    it 'allows valid website URLs' do
      distributor = build(:distributor, website_url: 'https://example.com')
      expect(distributor).to be_valid
    end

    it 'validates country_code format' do
      distributor = build(:distributor, country_code: 'USA')
      expect(distributor).not_to be_valid
      
      distributor.country_code = 'US'
      expect(distributor).to be_valid
    end
  end

  describe 'scopes' do
    let!(:active_distributor) { create(:distributor, active: true) }
    let!(:inactive_distributor) { create(:distributor, active: false) }
    let!(:us_distributor) { create(:distributor, country_code: 'US') }

    describe '.active' do
      it 'returns only active distributors' do
        expect(Distributor.active).to include(active_distributor)
        expect(Distributor.active).not_to include(inactive_distributor)
      end
    end

    describe '.by_country' do
      it 'returns distributors from specified country' do
        expect(Distributor.by_country('US')).to include(us_distributor)
      end
    end
  end
end