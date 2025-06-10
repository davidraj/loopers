require 'rails_helper'

RSpec.describe TvShow, type: :model do
  describe 'Analytical Methods' do
    let!(:drama_show) { create(:tv_show, title: 'Drama Series', genre: 'Drama', release_date: 1.year.ago) }
    let!(:comedy_show) { create(:tv_show, title: 'Comedy Series', genre: 'Comedy', release_date: 6.months.ago) }
    let!(:action_show) { create(:tv_show, title: 'Action Series', genre: 'Action', release_date: 2.years.ago) }
    
    let!(:distributor1) { create(:distributor, name: 'Netflix US', country_code: 'US', active: true) }
    let!(:distributor2) { create(:distributor, name: 'BBC UK', country_code: 'UK', active: true) }
    
    before do
      # Create episodes for shows
      create_list(:episode, 5, tv_show: drama_show, duration: 45)
      create_list(:episode, 3, tv_show: comedy_show, duration: 30)
      create_list(:episode, 8, tv_show: action_show, duration: 60)
      
      # Create distribution relationships
      create(:tv_show_distributor, 
        tv_show: drama_show, 
        distributor: distributor1, 
        exclusive: true,
        contract_start_date: 1.year.ago,
        contract_end_date: 6.months.from_now
      )
      
      create(:tv_show_distributor, 
        tv_show: comedy_show, 
        distributor: distributor2, 
        exclusive: false,
        contract_start_date: 6.months.ago,
        contract_end_date: 1.year.from_now
      )
    end

    describe '.shows_with_episode_stats' do
      it 'returns shows with episode statistics and rankings' do
        results = TvShow.shows_with_episode_stats
        
        expect(results).not_to be_empty
        
        # Check that results include expected attributes
        first_result = results.first
        expect(first_result).to respond_to(:title)
        expect(first_result).to respond_to(:genre)
        expect(first_result).to respond_to(:total_episodes)
        expect(first_result).to respond_to(:avg_episode_duration)
        expect(first_result).to respond_to(:genre_rank)
        expect(first_result).to respond_to(:overall_rank)
        
        # Verify the show with most episodes is ranked first
        top_show = results.find { |r| r.overall_rank.to_i == 1 }
        expect(top_show.title).to eq('Action Series')
        expect(top_show.total_episodes.to_i).to eq(8)
      end

      it 'calculates average episode duration correctly' do
        results = TvShow.shows_with_episode_stats
        
        drama_result = results.find { |r| r.title == 'Drama Series' }
        expect(drama_result.avg_episode_duration.to_f).to eq(45.0)
        
        comedy_result = results.find { |r| r.title == 'Comedy Series' }
        expect(comedy_result.avg_episode_duration.to_f).to eq(30.0)
      end

      it 'assigns genre rankings correctly' do
        results = TvShow.shows_with_episode_stats
        
        # Each show should be rank 1 in its genre since there's only one per genre
        results.each do |result|
          expect(result.genre_rank.to_i).to eq(1)
        end
      end
    end

    describe '.distribution_analysis' do
      it 'returns distribution statistics for active distributors' do
        results = TvShow.distribution_analysis
        
        expect(results).not_to be_empty
        
        # Check that results include expected attributes
        first_result = results.first
        expect(first_result).to respond_to(:distributor_name)
        expect(first_result).to respond_to(:country_code)
        expect(first_result).to respond_to(:shows_distributed)
        expect(first_result).to respond_to(:exclusive_deals)
        expect(first_result).to respond_to(:market_share_percentage)
      end

      it 'calculates exclusive deals correctly' do
        results = TvShow.distribution_analysis
        
        netflix_result = results.find { |r| r.distributor_name == 'Netflix US' }
        expect(netflix_result.exclusive_deals.to_i).to eq(1)
        
        bbc_result = results.find { |r| r.distributor_name == 'BBC UK' }
        expect(bbc_result.exclusive_deals.to_i).to eq(0)
      end

      it 'calculates market share percentage' do
        results = TvShow.distribution_analysis
        
        results.each do |result|
          expect(result.market_share_percentage.to_f).to be >= 0
          expect(result.market_share_percentage.to_f).to be <= 100
        end
      end
    end

    describe '.genre_performance_analysis' do
      it 'returns genre performance metrics with rankings' do
        results = TvShow.genre_performance_analysis
        
        expect(results).not_to be_empty
        expect(results.length).to eq(3) # Drama, Comedy, Action
        
        # Check that results include expected attributes
        first_result = results.first
        expect(first_result).to respond_to(:genre)
        expect(first_result).to respond_to(:total_shows)
        expect(first_result).to respond_to(:total_episodes)
        expect(first_result).to respond_to(:shows_rank)
        expect(first_result).to respond_to(:shows_percentile)
      end

      it 'ranks genres by total shows correctly' do
        results = TvShow.genre_performance_analysis
        
        # Since each genre has 1 show, rankings should be consistent
        results.each_with_index do |result, index|
          expect(result.shows_rank.to_i).to be_between(1, 3)
          expect(result.total_shows.to_i).to eq(1)
        end
      end

      it 'calculates episode totals correctly' do
        results = TvShow.genre_performance_analysis
        
        action_result = results.find { |r| r.genre == 'Action' }
        expect(action_result.total_episodes.to_i).to eq(8)
        
        drama_result = results.find { |r| r.genre == 'Drama' }
        expect(drama_result.total_episodes.to_i).to eq(5)
        
        comedy_result = results.find { |r| r.genre == 'Comedy' }
        expect(comedy_result.total_episodes.to_i).to eq(3)
      end
    end

    describe '.top_shows_by_episodes' do
      it 'returns shows ordered by episode count' do
        results = TvShow.top_shows_by_episodes(5)
        
        expect(results.first.title).to eq('Action Series')
        expect(results.first.episode_count.to_i).to eq(8)
        
        expect(results.second.title).to eq('Drama Series')
        expect(results.second.episode_count.to_i).to eq(5)
        
        expect(results.third.title).to eq('Comedy Series')
        expect(results.third.episode_count.to_i).to eq(3)
      end

      it 'respects the limit parameter' do
        results = TvShow.top_shows_by_episodes(2)
        expect(results.length).to eq(2)
      end
    end
  end
end