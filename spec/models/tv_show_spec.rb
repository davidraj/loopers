require 'rails_helper'

RSpec.describe TvShow, type: :model do
  # Use FactoryBot to create a valid subject
  subject { build(:tv_show) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:tvmaze_id).allow_nil }
  end

  describe 'associations' do
    it { should have_many(:episodes).dependent(:destroy) }
    it { should have_many(:user_tv_shows).dependent(:destroy) }
    it { should have_many(:users).through(:user_tv_shows) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(TvShow.defined_enums['status']).to eq({
        'upcoming' => 'upcoming',
        'running' => 'running',
        'ended' => 'ended'
      })
    end

    it 'allows setting status values' do
      tv_show = TvShow.new(title: 'Test')
      tv_show.status = :upcoming
      expect(tv_show.status).to eq('upcoming')
      expect(tv_show.upcoming?).to be true
    end
  end

  describe 'scopes' do
    let!(:upcoming_show) { create(:tv_show, status: :upcoming, title: 'Upcoming Show') }
    let!(:running_show) { create(:tv_show, status: :running, title: 'Running Show') }

    describe '.by_status' do
      it 'filters shows by status' do
        expect(TvShow.by_status(:upcoming)).to include(upcoming_show)
        expect(TvShow.by_status(:upcoming)).not_to include(running_show)
      end
    end

    describe '.search' do
      it 'searches shows by title' do
        expect(TvShow.search('Upcoming')).to include(upcoming_show)
        expect(TvShow.search('Upcoming')).not_to include(running_show)
      end
    end
  end
end