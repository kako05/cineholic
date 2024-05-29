class FilmsController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  def index
    @q = Film.ransack(params[:q])
    if params[:q].blank?
      @films = Film.all
    else
      @films = @q.result(distinct: true)
    end
  end

  def showing
    @films = Film.order(release_date: :desc).page(params[:page]).per(10)
  end

  def search
  end

  def show
    @film = Film.find(params[:id])
  end
end