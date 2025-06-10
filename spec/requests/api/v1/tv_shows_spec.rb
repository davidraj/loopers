require 'rails_helper'

RSpec.describe 'Api::V1::TvShows', type: :request do
  let!(:tv_shows) { create_list(:tv_show, 25) }
  let!(:breaking_bad) do
    create(:tv_show, 
           title: 'Breaking Bad',
           network_name: 'AMC',
           country_of_origin: 'United States',
           rating: 9.5,
           premiered_at: Date.parse('2008-01-20'))
  end
  let!(:sherlock) do
    create(:tv_show,
           title: 'Sherlock',
           network_name: 'BBC',
           country_of_origin: 'United Kingdom', 
           rating: 9.1,
           premiered_at: Date.parse('2010-07-25'))
  end

  describe 'GET /api/v1/tvshows' do
    context 'successful responses' do
      it 'returns paginated TV shows with metadata' do
        get '/api/v1/tvshows'
        
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')
        
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
        expect(json).to have_key('meta')
        expect(json).to have_key('filters_applied')
        
        expect(json['data']).to be_an(Array)
        expect(json['data'].length).to eq(20) # default per_page
        
        expect(json['meta']).to include(
          'current_page' => 1,
          'per_page' => 20,
          'total_pages' => 2,
          'total_count' => 27
        )
      end

      it 'returns correct TV show structure' do
        get '/api/v1/tvshows'
        
        json = JSON.parse(response.body)
        show = json['data'].first
        
        expect(show).to include(
          'id', 'title', 'genre', 'status', 'rating',
          'network_name', 'country_of_origin', 'language',
          'runtime_minutes', 'premiered_at', 'summary',
          'image_url', 'episodes_count', 'created_at', 'updated_at'
        )
      end

      it 'sets appropriate cache headers' do
        get '/api/v1/tvshows'
        
        expect(response.headers['Cache-Control']).to include('public')
        expect(response.headers['Cache-Control']).to include('max-age=3600')
        expect(response.headers['ETag']).to be_present
      end
    end

    context 'pagination' do
      it 'handles custom page size' do
        get '/api/v1/tvshows', params: { per_page: 5 }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(5)
        expect(json['meta']['per_page']).to eq(5)
        expect(json['meta']['total_pages']).to eq(6)
      end

      it 'handles page navigation' do
        get '/api/v1/tvshows', params: { page: 2, per_page: 10 }
        
        json = JSON.parse(response.body)
        expect(json['meta']['current_page']).to eq(2)
        expect(json['data'].length).to eq(10)
      end

      it 'handles last page correctly' do
        get '/api/v1/tvshows', params: { page: 2, per_page: 20 }
        
        json = JSON.parse(response.body)
        expect(json['meta']['current_page']).to eq(2)
        expect(json['data'].length).to eq(7) # remaining shows
      end
    end

    context 'filtering by date range' do
      it 'filters shows by date range' do
        get '/api/v1/tvshows', params: {
          date_from: '2008-01-01',
          date_to: '2008-12-31'
        }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['title']).to eq('Breaking Bad')
        expect(json['filters_applied']).to include(
          'date_from' => '2008-01-01',
          'date_to' => '2008-12-31'
        )
      end

      it 'returns empty results for non-matching date range' do
        get '/api/v1/tvshows', params: {
          date_from: '2000-01-01',
          date_to: '2000-12-31'
        }
        
        json = JSON.parse(response.body)
        expect(json['data']).to be_empty
        expect(json['meta']['total_count']).to eq(0)
      end
    end

    context 'filtering by distributor/network' do
      it 'filters shows by distributor name' do
        get '/api/v1/tvshows', params: { distributor: 'AMC' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['network_name']).to include('AMC')
        expect(json['filters_applied']['distributor']).to eq('AMC')
      end

      it 'performs case-insensitive distributor search' do
        get '/api/v1/tvshows', params: { distributor: 'amc' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['network_name']).to include('AMC')
      end

      it 'performs partial distributor matching' do
        get '/api/v1/tvshows', params: { distributor: 'BB' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['network_name']).to include('BBC')
      end
    end

    context 'filtering by country' do
      it 'filters shows by country' do
        get '/api/v1/tvshows', params: { country: 'United States' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['country_of_origin']).to eq('United States')
        expect(json['filters_applied']['country']).to eq('United States')
      end

      it 'performs case-insensitive country search' do
        get '/api/v1/tvshows', params: { country: 'united kingdom' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['country_of_origin']).to eq('United Kingdom')
      end
    end

    context 'filtering by rating' do
      it 'filters shows by minimum rating' do
        get '/api/v1/tvshows', params: { rating: '9.0' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(2)
        json['data'].each do |show|
          expect(show['rating']).to be >= 9.0
        end
        expect(json['filters_applied']['rating']).to eq('9.0')
      end

      it 'filters shows by high rating threshold' do
        get '/api/v1/tvshows', params: { rating: '9.5' }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['title']).to eq('Breaking Bad')
      end
    end

    context 'combined filters' do
      it 'applies multiple filters simultaneously' do
        get '/api/v1/tvshows', params: {
          country: 'United States',
          rating: '9.0',
          per_page: 5
        }
        
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(1)
        expect(json['data'].first['title']).to eq('Breaking Bad')
        expect(json['filters_applied']).to include(
          'country' => 'United States',
          'rating' => '9.0'
        )
        expect(json['meta']['per_page']).to eq(5)
      end
    end

    context 'error cases' do
      it 'handles invalid date format gracefully' do
        get '/api/v1/tvshows', params: {
          date_from: 'invalid-date',
          date_to: '2020-12-31'
        }
        
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end

      it 'handles invalid page numbers' do
        get '/api/v1/tvshows', params: { page: 999 }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).to be_empty
        expect(json['meta']['current_page']).to eq(999)
      end

      it 'handles invalid rating values' do
        get '/api/v1/tvshows', params: { rating: 'invalid' }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        # Should return all shows since invalid rating is ignored
        expect(json['data'].length).to eq(20)
      end
    end

    context 'deterministic responses' do
      it 'returns consistent ordering across requests' do
        get '/api/v1/tvshows'
        first_response = JSON.parse(response.body)
        
        get '/api/v1/tvshows'
        second_response = JSON.parse(response.body)
        
        expect(first_response['data']).to eq(second_response['data'])
      end

      it 'maintains consistent ETag for same parameters' do
        get '/api/v1/tvshows', params: { rating: '8.0' }
        first_etag = response.headers['ETag']
        
        get '/api/v1/tvshows', params: { rating: '8.0' }
        second_etag = response.headers['ETag']
        
        expect(first_etag).to eq(second_etag)
      end
    end
  end
end
