class Api::V1::TvShowsController < ApplicationController
  before_action :set_tv_show, only: [:show, :update, :destroy]

  def index
    @tv_shows = TvShow.includes(:episodes, :distributors)
    
    # Apply filters if provided
    @tv_shows = @tv_shows.by_genre(params[:genre]) if params[:genre].present?
    @tv_shows = @tv_shows.released_after(params[:released_after]) if params[:released_after].present?
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = [params[:per_page]&.to_i || 10, 100].min
    
    @tv_shows = @tv_shows.limit(per_page).offset((page - 1) * per_page)
    
    render json: {
      data: @tv_shows.map { |show| tv_show_json(show) },
      meta: {
        page: page,
        per_page: per_page,
        total: TvShow.count
      }
    }
  end

  def show
    render json: { data: tv_show_json(@tv_show) }
  end

  def create
    @tv_show = TvShow.new(tv_show_params)
    
    if @tv_show.save
      render json: { data: tv_show_json(@tv_show) }, status: :created
    else
      render json: { errors: @tv_show.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @tv_show.update(tv_show_params)
      render json: { data: tv_show_json(@tv_show) }
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
    params.require(:tv_show).permit(:title, :genre, :release_date)
  end

  def tv_show_json(show)
    {
      id: show.id,
      title: show.title,
      genre: show.genre,
      release_date: show.release_date,
      episodes_count: show.episodes.count,
      distributors: show.distributors.map { |d| { id: d.id, name: d.name } },
      created_at: show.created_at,
      updated_at: show.updated_at
    }
  end
end
