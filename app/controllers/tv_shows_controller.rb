class TvShowsController < ApplicationController
  def index
    @tv_shows = TvShow.includes(:episodes).order(:title).limit(50)
  end

  def show
    @tv_show = TvShow.find(params[:id])
    @episodes = @tv_show.episodes.order(:season_number, :episode_number)
  end
end
