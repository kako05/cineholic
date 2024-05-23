class FilmsController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  def index
  end

  def showing
    @films = Film.order(released_at: :desc)
    url = "https://jfdb.jp/now_showing"
    doc = Nokogiri::HTML(URI.open(url))
    @films = doc.css("article#title").map do |film_element|
      {
        title: film_element.css(".title-main").text.strip,
        poster: film_element.css(".title-photo img").first.attr('src'),
        summary: film_element.css(".description").text.strip
      }
    end
    render :showing
  end

  def search
    url = "https://jfdb.jp/search"
    doc = Nokogiri::HTML(URI.open(url))
    @films = doc.css("article#title").map do |result_element|
      {
        title: result_element.css(".title-main").text.strip,
        poster: result_element.css(".title-photo img").first.attr('src'),
        summary: result_element.css(".description").text.strip
      }
    end
    render :search
  end

  def show_details
    @film = Film.find(params[:id])
  end
end
