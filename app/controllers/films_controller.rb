class FilmsController < ApplicationController
  before_action :set_q, only: [:index, :search]

  def index
    @films = if params[:q].present? || search_params_present?
               FilmSearchQuery.new(params).call.page(params[:page]).per(10)
             else
               Film.all.page(params[:page]).per(10)
             end
  end

  def showing
    @films = Film.order(release_date: :desc).page(params[:page]).per(10)
  end

  def search
    @films = FilmSearchQuery.new(params).call.page(params[:page]).per(10)
  end

  def show
    @film = Film.find(params[:id])
    @casts = @film.casts
    @trailers = @film.trailers
  end

  private

  def set_q
    @q = Film.ransack(params[:q])
  end

  def search_params_present?
    params.values_at(:search_title, :search_cast, :search_staff).any?(&:present?)
  end
end