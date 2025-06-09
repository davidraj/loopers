require 'rails_helper'
require 'webmock/rspec'

RSpec.describe TvMazeUpcomingService, type: :service do
  let(:service) { described_class.new }
  let(:sample_date) { Date.current.strftime('%Y-%m-%d') }
  
  describe '#fetch_upcoming_releases' do
    context 'when API returns successful response' do
      before do
        stub_tvmaze_schedule_api
      end
      
      it 'returns success response with processed data' do
        result = service.fetch_upcoming_releases(1)
        
        expect(result[:success]).to be true
        expect(result[:total_episodes]).to eq(2)
        expect(result[:processed_shows]).to eq(2)
        expect(result[:message]).to include('Successfully processed')
      end
      
      it 'creates TV shows from episode data' do
        expect { service.fetch_upcoming_releases(1) }
          .to change(TvShow, :count).by(2)
      end
      
      it 'creates release dates for episodes' do
        expect { service.fetch_upcoming_releases(1) }
          .to change(ReleaseDate, :count).by_at_least(2)
      end
      
      it 'creates distributors from network data' do
        expect { service.fetch_upcoming_releases(1) }
          .to change(Distributor, :count).by_at_least(1)
      end
    end
    
    context 'when API returns error' do
      before do
        stub_request(:get, /api\.tvmaze\.com\/schedule/)
          .to_return(status: 500, body: 'Internal Server Error')
      end
      
      it 'handles API errors gracefully' do
        result = service.fetch_upcoming_releases(1)
        
        expect(result[:success]).to be true
        expect(result[:total_episodes]).to eq(0)
      end
    end
    
    context 'when network timeout occurs' do
      before do
        stub_request(:get, /api\.tvmaze\.com\/schedule/)
          .to_timeout
      end
      
      it 'handles network timeouts' do
        result = service.fetch_upcoming_releases(1)
        
        expect(result[:success]).to be true
        expect(result[:total_episodes]).to eq(0)
      end
    end
    
    context 'when invalid JSON is returned' do
      before do
        stub_request(:get, /api\.tvmaze\.com\/schedule/)
          .to_return(status: 200, body: 'invalid json')
      end
      
      it 'handles JSON parsing errors' do
        result = service.fetch_upcoming_releases(1)
        
        expect(result[:success]).to be true
        expect(result[:total_episodes]).to eq(0)
      end
    end
  end
  
  describe 'idempotency' do
    before do
      stub_tvmaze_schedule_api
    end
    
    it 'does not create duplicate shows on multiple runs' do
      service.fetch_upcoming_releases(1)
      initial_count = TvShow.count
      
      service.fetch_upcoming_releases(1)
      
      expect(TvShow.count).to eq(initial_count)
    end
    
    it 'does not create duplicate release dates' do
      service.fetch_upcoming_releases(1)
      initial_count = ReleaseDate.count
      
      service.fetch_upcoming_releases(1)
      
      expect(ReleaseDate.count).to eq(initial_count)
    end
    
    it 'updates existing shows with newer data' do
      # First run
      service.fetch_upcoming_releases(1)
      show = TvShow.find_by(title: 'Test Show')
    end
  end
end