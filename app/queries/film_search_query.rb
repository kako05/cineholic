class FilmSearchQuery
  require 'romaji'
  def initialize(params)
    @params = params
  end

  def call
    films = Film.all

    if @params[:q_cont].present?
      # 入力されたキーワードを正規化
      normalized_keywords = normalize_search_term(@params[:q_cont])
      # データベースからの取得結果も正規化
      films = films.joins(:casts, :trailers, :film_casts, :film_trailers).distinct
      # 各キーワードと条件を結合してクエリを作成
      conditions, values = build_conditions_and_values(normalized_keywords)
      full_query = conditions.join(' OR ')
      # 検索実行
      films = films.where(full_query, *values)
    end

    films
  end

  private

  def build_conditions_and_values(normalized_keywords)
    conditions = []
    values = []
    # タイトルがtrueの場合の条件を追加
    if @params[:search_title] == "1"
      add_search_conditions(conditions, values, normalized_keywords, "films.title")
    end

   # 役者名がtrueの場合の条件を追加
    if @params[:search_cast] == "1"
      add_search_conditions(conditions, values, normalized_keywords, "casts.name")
    end

    # スタッフ名がtrueの場合の条件を追加
    if @params[:search_staff] == "1"
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

    [conditions, values]
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
end
