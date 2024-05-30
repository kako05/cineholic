class FilmsController < ApplicationController
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
      keyword = normalize_search_term(params[:q_cont])

      if search_params_present?
        films = films.none # 初期化してから条件を適用

        if params[:search_title].present?
          films = films.or(Film.where("title LIKE :q", q: keyword))
        end

        if params[:search_cast].present?
          films = films.or(Film.joins(:casts).where("casts.name LIKE :q", q: keyword))
        end

        if params[:search_staff].present?
          films = films.or(Film.joins(:trailers).where("trailers.name LIKE :q", q: keyword))
        end
      else
        films = films.joins("LEFT JOIN film_casts ON films.id = film_casts.film_id")
                     .joins("LEFT JOIN casts ON film_casts.cast_id = casts.id")
                     .joins("LEFT JOIN film_trailers ON films.id = film_trailers.film_id")
                     .joins("LEFT JOIN trailers ON film_trailers.trailer_id = trailers.id")
                     .where("title LIKE :q OR casts.name LIKE :q OR trailers.name LIKE :q", q: keyword)
      end
    end

    films = films.distinct

    if films.empty?
      flash.now[:alert] = '映画が見つかりません'
    end

    films
  end

  def normalize_search_term(term)
    term_kanji = term.tr('a-zA-Z', 'ａ-ｚＡ-Ｚ')
    term_kana = NKF.nkf('-w -Z1 -x', term)
    term_hira = NKF.nkf('-w -Z1 -X', term)

    ["%#{term_kanji}%", "%#{term_kana}%", "%#{term_hira}%"]
  end

  def search_params_present?
    params.values_at(:search_title, :search_cast, :search_staff).any?(&:present?)
  end
end