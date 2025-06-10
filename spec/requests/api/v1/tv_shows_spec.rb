require 'rails_helper'

RSpec.describe 'Api::V1::TvShows', type: :request do
  let!(:tv_shows) { create_list(:tv_show, 5) }
  let(:tv_show) { tv_shows.first }
  let(:headers) { { 'Content-Type' => 'application/json' } }

  describe 'GET /api/v1/tvshows' do
    context 'without filters' do
      before { get '/api/v1/tvshows', headers: headers }

      it 'returns success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all tv shows' do
        json_response = JSON.parse(response.body)
        expect(json_response['tv_shows'].length).to eq(5)
      end

      it 'includes pagination info' do
        json_response = JSON.parse(response.body)
        expect(json_response['pagination']).to include(
          'current_page' => 1,
          'per_page' => 10,
          'total_pages' => 1,
          'total_count' => 5
        )
      end

      it 'returns expected tv show attributes' do
        json_response = JSON.parse(response.body)
        tv_show_json = json_response['tv_shows'].first
        
        expect(tv_show_json).to include(
          'id', 'title', 'description', 'genre', 'total_seasons',
          'total_episodes', 'status', 'imdb_rating', 'language',
          'runtime_minutes', 'original_air_date', 'country_of_origin',
          'network_name', 'rating'
        )
      end
    end

    context 'with pagination' do
      before { get '/api/v1/tvshows?page=1&per_page=2', headers: headers }

      it 'respects per_page parameter' do
        json_response = JSON.parse(response.body)
        expect(json_response['tv_shows'].length).to eq(2)
      end

      it 'returns correct pagination info' do
        json_response = JSON.parse(response.body)
        expect(json_response['pagination']).to include(
          'current_page' => 1,
          'per_page' => 2,
          'total_pages' => 3,
          'total_count' => 5
        )
      end
    end

    context 'with country filter' do
      let!(:us_show) { create(:tv_show, :us_show) }
      let!(:uk_show) { create(:tv_show, :uk_show) }

      before { get '/api/v1/tvshows?country=United States', headers: headers }

      it 'filters by country' do
        json_response = JSON.parse(response.body)
        titles = json_response['tv_shows'].map { |show| show['id'] }
        expect(titles).to include(us_show.id)
        expect(titles).not_to include(uk_show.id)
      end
    end

    context 'with rating filter' do
      let!(:high_rated_show) { create(:tv_show, :high_rated) }
      let!(:low_rated_show) { create(:tv_show, imdb_rating: 6.0) }

      before { get '/api/v1/tvshows?rating=8.0', headers: headers }

      it 'filters by minimum rating' do
        json_response = JSON.parse(response.body)
        ratings = json_response['tv_shows'].map { |show| show['imdb_rating'].to_f }
        expect(ratings).to all(be >= 8.0)
      end
    end

    context 'with genre filter' do
      let!(:drama_show) { create(:tv_show, genre: 'Drama') }
      let!(:comedy_show) { create(:tv_show, genre: 'Comedy') }

      before { get '/api/v1/tvshows?genre=Drama', headers: headers }

      it 'filters by genre' do
        json_response = JSON.parse(response.body)
        genres = json_response['tv_shows'].map { |show| show['genre'] }
        expect(genres).to all(include('Drama'))
      end
    end
  end

  describe 'GET /api/v1/tvshows/:id' do
    context 'when tv show exists' do
      before { get "/api/v1/tvshows/#{tv_show.id}", headers: headers }

      it 'returns success status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the tv show' do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(tv_show.id)
        expect(json_response['title']).to eq(tv_show.title)
      end

      it 'includes all expected attributes' do
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'id', 'title', 'description', 'genre', 'total_seasons',
          'total_episodes', 'status', 'imdb_rating', 'language',
          'runtime_minutes', 'original_air_date', 'country_of_origin',
          'network_name', 'rating', 'summary', 'image_url', 'tvmaze_id',
          'premiered_at'
        )
      end
    end

    context 'when tv show does not exist' do
      before { get '/api/v1/tvshows/999999', headers: headers }

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('TV Show not found')
      end
    end
  end
end
