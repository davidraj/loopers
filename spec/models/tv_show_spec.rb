require 'rails_helper'

RSpec.describe TvShow, type: :model do
  describe 'associations' do
    it { should have_many(:tv_show_distributors).dependent(:destroy) }
    it { should have_many(:distributors).through(:tv_show_distributors) }
    it { should have_many(:release_dates).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_inclusion_of(:status).in_array(%w[upcoming airing ended cancelled]) }
    
    it 'validates IMDB rating range' do
      show = build(:tv_show, imdb_rating: 11.0)
      expect(show).not_to be_valid
      
      show.imdb_rating = 8.5
      expect(show).to be_valid
    end

    it 'validates positive numbers for seasons, episodes, runtime' do
      show = build(:tv_show, total_seasons: -1)
      expect(show).not_to be_valid
      
      show.total_seasons = 5
      expect(show).to be_valid
    end
  end

  describe 'scopes' do
    let!(:comedy_show) { create(:tv_show, genre: 'comedy') }
    let!(:drama_show) { create(:tv_show, genre: 'drama') }
    let!(:airing_show) { create(:tv_show, status: 'airing') }
    let!(:high_rated_show) { create(:tv_show, imdb_rating: 9.0) }

    describe '.by_genre' do
      it 'returns shows of specified genre' do
        expect(TvShow.by_genre('comedy')).to include(comedy_show)
        expect(TvShow.by_genre('comedy')).not_to include(drama_show)
      end
    end

    describe '.by_status' do
      it 'returns shows with specified status' do
        expect(TvShow.by_status('airing')).to include(airing_show)
      end
    end

    describe '.top_rated' do
      it 'returns shows ordered by rating descending' do
        expect(TvShow.top_rated.first).to eq(high_rated_show)
      end
    end
  end
end