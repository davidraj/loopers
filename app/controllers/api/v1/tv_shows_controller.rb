class Api::V1::TvShowsController < ApplicationController
  before_action :set_tv_show, only: [:show, :update, :destroy]

  def index
    @tv_shows = TvShow.includes(:episodes, :distributors)
    
    # Apply filters if provided
    @tv_shows = @tv_shows.by_genre(params[:genre]) if params[:genre].present?
    @tv_shows = @tv_shows.released_after(params[:released_after]) if params[:released_after].present?
    
    # Add country filter
    @tv_shows = @tv_shows.where(country_of_origin: params[:country]) if params[:country].present?
    
    # Add rating filter
    @tv_shows = @tv_shows.where('imdb_rating >= ?', params[:rating]) if params[:rating].present?
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 10, 100].min
    
    total_count = @tv_shows.count
    @tv_shows = @tv_shows.limit(per_page).offset((page - 1) * per_page)
    
    render json: {
      tv_shows: @tv_shows.map { |show| tv_show_json(show) },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count
      }
    }
  end

  def show
    render json: tv_show_json(@tv_show)
  end

  def create
    @tv_show = TvShow.new(tv_show_params)
    
    if @tv_show.save
      render json: tv_show_json(@tv_show), status: :created
    else
      render json: { errors: @tv_show.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @tv_show.update(tv_show_params)
      render json: tv_show_json(@tv_show)
    else
      render json: { errors: @tv_show.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @tv_show.destroy
    head :no_content
  end

  private

  def set_tv_show
    @tv_show = TvShow.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'TV Show not found' }, status: :not_found
  end

  def tv_show_params
    params.require(:tv_show).permit(:title, :description, :genre, :total_seasons, 
                                   :total_episodes, :status, :imdb_rating, :language,
                                   :runtime_minutes, :original_air_date, :country_of_origin,
                                   :network_name, :rating, :summary, :image_url, :tvmaze_id,
                                   :premiered_at)
  end

  def tv_show_json(show)
    {
      id: show.id,
      title: show.title,
      description: show.description,
      genre: show.genre,
      total_seasons: show.total_seasons,
      total_episodes: show.total_episodes,
      status: show.status,
      imdb_rating: show.imdb_rating,
      language: show.language,
      runtime_minutes: show.runtime_minutes,
      original_air_date: show.original_air_date,
      country_of_origin: show.country_of_origin,
      network_name: show.network_name,
      rating: show.rating,
      summary: show.summary,
      image_url: show.image_url,
      tvmaze_id: show.tvmaze_id,
      premiered_at: show.premiered_at,
      created_at: show.created_at,
      updated_at: show.updated_at
    }
  end
end
