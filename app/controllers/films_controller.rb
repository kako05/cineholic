class FilmsController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  def index
  end

  def showing
    @films = Film.order(release_year: :desc).page(params[:page]).per(10)
  end

  def search
  end

  def show
    @film = Film.find(params[:id])
  end
end