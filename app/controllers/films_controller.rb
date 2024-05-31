class FilmsController < ApplicationController
  require 'nkf'
  before_action :set_q, only: [:index, :search]

  def index
    @films = if params[:q].present? || search_params_present?
               search_films.page(params[:page]).per(10)
             else
               Film.all.page(params[:page]).per(10)
             end
  end

  def showing
    @films = Film.order(release_date: :desc).page(params[:page]).per(10)
  end

  def search
    @films = search_films.page(params[:page]).per(10)
  end

  private

  def set_q
    @q = Film.ransack(params[:q])
  end

  def search_films
    films = Film.all
  
    if params[:q_cont].present?
      keywords = normalize_search_term(params[:q_cont]).split(' ')
      films = films.joins("LEFT JOIN film_casts ON films.id = film_casts.film_id")
                   .joins("LEFT JOIN casts ON film_casts.cast_id = casts.id")
                   .joins("LEFT JOIN film_trailers ON films.id = film_trailers.film_id")
                   .joins("LEFT JOIN trailers ON film_trailers.trailer_id = trailers.id")
  
      # 検索条件を設定する
      conditions = []
  
      # タイトルがtrue
      conditions << "LOWER(films.title) LIKE :q" if params[:search_title] == "1"
  
      # 役者名がtrue
      conditions << "LOWER(casts.name) LIKE :q" if params[:search_cast] == "1"
  
      # スタッフ名がtrue
      conditions << "LOWER(trailers.name) LIKE :q" if params[:search_staff] == "1"
  
      # チェックボックスがすべてfalseのときdescriptionとtextカラムを除外して検索
      if conditions.empty?
        columns_to_search = (Film.column_names - ["description"]) + (Trailer.column_names - ["text"])
        columns_to_search.each do |column|
          conditions << "LOWER(films.#{column}) LIKE :q"
        end
      end
  
      # 各キーワードに対して部分一致検索を行う
      keyword_conditions = []
      conditions.each do |condition|
        keyword_conditions << keywords.map { |keyword| "#{condition}" }
      end
  
      # キーワードと条件を結合
      query = keyword_conditions.flatten.join(" OR ")
      films = films.where(query, q: keywords.map { |keyword| "%#{keyword}%" })
  
      films = films.distinct
    end
  
    # 映画が見つからない場合の処理
    if films.empty?
      flash.now[:alert] = '映画が見つかりません'
    end
  
    films
  end
  

  def normalize_search_term(term)
    term = NKF.nkf('-w -Z1', term) # 入力文字列を半角に変換
    term.downcase! # 入力文字列を小文字に変換
    term.gsub!(/\s+/, '%') # 空白を '%' に変換して部分一致検索に対応
    "%#{term}%"
  end

  def search_params_present?
    params.values_at(:search_title, :search_cast, :search_staff).any?(&:present?)
  end
end
