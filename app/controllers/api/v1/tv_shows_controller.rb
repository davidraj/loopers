class Api::V1::TvShowsController < ApplicationController
  before_action :set_tv_show, only: [:show]

  def index
    @tv_shows = TvShow.all
    
    # Apply filters
    @tv_shows = @tv_shows.by_rating(params[:rating]) if params[:rating].present?
    @tv_shows = @tv_shows.by_country(params[:country]) if params[:country].present?
    @tv_shows = @tv_shows.by_genre(params[:genre]) if params[:genre].present?
    
    if params[:date_from].present? && params[:date_to].present?
      @tv_shows = @tv_shows.by_date_range(params[:date_from], params[:date_to])
    end
    
    # Pagination
    page = params[:page] || 1
    per_page = [params[:per_page].to_i, 50].min
    per_page = 10 if per_page <= 0
    
    @tv_shows = @tv_shows.page(page).per(per_page)
    
    render json: {
      tv_shows: @tv_shows.as_json(
        only: [:id, :title, :description, :genre, :total_seasons, :total_episodes, 
               :status, :imdb_rating, :language, :runtime_minutes, :original_air_date, 
               :country_of_origin, :network_name, :rating]
      ),
      pagination: {
        current_page: @tv_shows.current_page,
        per_page: @tv_shows.limit_value,
        total_pages: @tv_shows.total_pages,
        total_count: @tv_shows.total_count
      }
    }
  end

  def show
    render json: @tv_show.as_json(
      only: [:id, :title, :description, :genre, :total_seasons, :total_episodes, 
             :status, :imdb_rating, :language, :runtime_minutes, :original_air_date, 
             :country_of_origin, :network_name, :rating, :summary, :image_url, :tvmaze_id, :premiered_at]
    )
  end

  private

  def set_tv_show
    @tv_show = TvShow.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'TV Show not found' }, status: :not_found
  end
end
