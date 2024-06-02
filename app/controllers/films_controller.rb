class FilmsController < ApplicationController
  require 'romaji'
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
      normalized_keywords = normalize_search_term(params[:q_cont])

      # データベースからの取得結果も正規化
      films = films.joins(:casts, :trailers, :film_casts, :film_trailers).distinct
      # films = films.joins("LEFT JOIN film_casts ON films.id = film_casts.film_id")
      #              .joins("LEFT JOIN casts ON film_casts.cast_id = casts.id")
      #              .joins("LEFT JOIN film_trailers ON films.id = film_trailers.film_id")
      #              .joins("LEFT JOIN trailers ON film_trailers.trailer_id = trailers.id")
      #              .distinct

      # 検索条件を設定する
      conditions = []
      values = []

      # タイトルがtrueの場合の条件を追加
      if params[:search_title] == "1"
        add_search_conditions(conditions, values, normalized_keywords, "films.title")
      end

      # 役者名がtrueの場合の条件を追加
      if params[:search_cast] == "1"
        add_search_conditions(conditions, values, normalized_keywords, "casts.name")
      end

      # スタッフ名がtrueの場合の条件を追加
      if params[:search_staff] == "1"
        add_search_conditions(conditions, values, normalized_keywords, "trailers.name")
      end

      # チェックボックスがすべてfalseの場合
      if conditions.empty?
        # Filmモデルのdescription以外のカラムを対象にする
        Film.column_names.each do |column|
          next if column == "description"
          add_search_conditions(conditions, values, normalized_keywords, "films.#{column}")
        end

        # Castモデルの全てのカラムを対象にする
        Cast.column_names.each do |column|
          add_search_conditions(conditions, values, normalized_keywords, "casts.#{column}")
        end

        # Trailerモデルのtext以外のカラムを対象にする
        Trailer.column_names.each do |column|
          next if column == "text"
          add_search_conditions(conditions, values, normalized_keywords, "trailers.#{column}")
        end
      end

      # 各キーワードと条件を結合してクエリを作成
      full_query = conditions.join(' OR ')

      # 検索実行
      films = films.where(full_query, *values)
      # films = films.where(full_query, *normalized_keywords.map { |kw| "%#{kw}%" })
    end

    # 映画が見つからない場合の処理
    if films.empty?
      flash.now[:alert] = '映画が見つかりません'
    end

    films
  end

  def add_search_conditions(conditions, values, keywords, column)
    keywords.each do |keyword|
      conditions << "#{column} LIKE ?"
      values << "%#{keyword}%"
    end
  end

  def normalize_search_term(term)
    term = term.downcase # 入力文字列を小文字に変換
    term = term.unicode_normalize(:nfkc) # Unicode正規化を適用する
    generate_variants(term) # カタカナ、ひらがな、漢字、英字のバリエーションを生成
  end

  def generate_variants(term)
    variants = [term]
    if term =~ /\p{Hiragana}/
      # ひらがなをカタカナに変換
      variants << term.tr('ぁ-ん', 'ァ-ン')
      # ひらがなをローマ字に変換
      variants << Romaji.kana2romaji(term)
    elsif term =~ /\p{Katakana}/
      # カタカナをひらがなに変換
      variants << term.tr('ァ-ン', 'ぁ-ん')
      # カタカナをローマ字に変換
      variants << Romaji.kana2romaji(term)
    elsif term =~ /\p{Alnum}/
      # ローマ字をカタカナに変換（romaji gemにはこの機能がないため、自前で変換）
      variants << Romaji.romaji2kana(term)
      # カタカナをひらがなに変換
      variants << Romaji.romaji2kana(term).tr('ァ-ン', 'ぁ-ん')
    end
  variants.uniq.map { |variant| "%#{variant}%" }
  end

  def search_params_present?
    params.values_at(:search_title, :search_cast, :search_staff).any?(&:present?)
  end
end