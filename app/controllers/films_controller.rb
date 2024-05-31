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
      # 入力されたキーワードを正規化
      normalized_keywords = normalize_search_term(params[:q_cont]).split(' ')

      # データベースからの取得結果も正規化
      films = films.joins("LEFT JOIN film_casts ON films.id = film_casts.film_id")
                   .joins("LEFT JOIN casts ON film_casts.cast_id = casts.id")
                   .joins("LEFT JOIN film_trailers ON films.id = film_trailers.film_id")
                   .joins("LEFT JOIN trailers ON film_trailers.trailer_id = trailers.id")
                   .distinct

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
        film_conditions = []
        (Film.column_names - ["description"]).each do |column|
          film_conditions << "LOWER(films.#{column}) LIKE :q"
        end
        conditions << film_conditions.join(" OR ")

        cast_conditions = []
        Cast.column_names.each do |column|
          cast_conditions << "LOWER(casts.#{column}) LIKE :q"
        end
        conditions << cast_conditions.join(" OR ")

        trailer_conditions = []
        (Trailer.column_names - ["text"]).each do |column|
          trailer_conditions << "LOWER(trailers.#{column}) LIKE :q"
        end
        conditions << trailer_conditions.join(" OR ")
      end

      # 各キーワードと条件を結合してクエリを作成
      queries = []
      conditions.each do |condition|
        normalized_keywords.each do |keyword|
          queries << condition.gsub(':q', "'%#{keyword}%'")
        end
      end

      # クエリを結合
      full_query = queries.join(' OR ')

      # 検索実行
      films = films.where(full_query)
    end

    # 映画が見つからない場合の処理
    if films.empty?
      flash.now[:alert] = '映画が見つかりません'
    end

    films
  end

  def normalize_search_term(term)
    term = term.downcase # 入力文字列を小文字に変換
    term = term.tr('ぁ-ん','ァ-ン') # ひらがなをカタカナに変換
    term = term.tr('ａ-ｚ','Ａ-Ｚ') # 全角英字を半角英字に変換
    term = term.tr('Ａ-Ｚ','A-Za-z') # 大文字英字を小文字英字に変換
    term = term.unicode_normalize(:nfkc) # Unicode正規化を適用する
    term.gsub!(/\s+/, '%') # 空白を '%' に変換して部分一致検索に対応
    "%#{term}%"
  end

  def search_params_present?
    params.values_at(:search_title, :search_cast, :search_staff).any?(&:present?)
  end
end