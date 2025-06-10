class TvShowsController < ApplicationController
  before_action :set_tv_show, only: [:show]

  def index
    @tv_shows = TvShow.all.limit(10)
  end

  def show
  end

  private

  def set_tv_show
    @tv_show = TvShow.find(params[:id])
  end
end
