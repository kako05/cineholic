require "open-uri"
require "nokogiri"

namespace :films do
  desc "Scrape and save latest films"
  task scrape_300: :environment do
    base_url = "http://jfdb.jp"
    start_page = 1 # ページ1から開始
    page_size = 3 # 1ページあたり3件を処理

    loop do
      index_url = "#{base_url}/search/title?ORDER=RELE_D&START=#{start_page}" # 公開日で降順に並べ替え

      begin
        # データを取得
        index_doc = Nokogiri::HTML(URI.open(index_url))
      rescue => e
        puts "インデックスページのスクレイピング中にエラーが発生しました: #{e.message}"
        return
      end

      # 1ページあたり300件を処理
      index_doc.css('.search-result-item').each_with_index do |item, i|
        if i >= page_size
          break
        end

        title = item.css('.list-title a').text.strip

        # タイトルが空の場合はスキップ
        next if title.empty?

        # 映画レコードを検索または作成
        film = Film.find_or_create_by(title: title)

        description = item.css('.title-description').text.strip
        release_year_element = item.css('small.prod_year').first

        # release_year_element が存在し、かつテキストが存在するか確認
        release_year = nil
        if release_year_element
          release_year_text = release_year_element.text.strip
          if release_year_text.match(/\((\d+)\)/)
            release_year = release_year_text.match(/\((\d+)\)/)[1].to_i
          end
        end

        poster_image_url = item.css('.list-img-top img').attr('src').value
        link = item.css('.list-title a').attr('href').value
        film_url = "#{base_url}#{link}"

        begin
          # 映画の詳細ページを取得
          detail_doc = Nokogiri::HTML(URI.open(film_url))
        rescue => e
          puts "映画「#{title}」の詳細ページのスクレイピング中にエラーが発生しました: #{e.message}"
          next
        end

        # スタッフ情報を抽出して保存
        staff_info = {}
        detail_doc.css('.title-detail ul li').each do |staff_item|
          staff_name = staff_item.css('a').text.strip
          role = staff_item.text.strip.split(/─|ー/)[1].strip # ハイフン/ダッシュを区切り文字として使用

          # 録音/音響および美術/美術監督の役割を統合
          if role == "録音" || role == "音響"
            role = "録音・音響"
          end

          if role == "美術" || role == "美術監督"
            role = "美術"
          end

          if role == "衣装" || role == "衣裳" || role == "スタイリスト"
            role = "衣装"
          end

          staff_info[role] ||= []
          staff_info[role] << staff_name
        end

        # キャスト情報を抽出して保存
        casts = detail_doc.css('.cast-list ul li').map do |cast_item|
          cast_item.css('a').text.strip
        end

        # 映画データを更新
        film.update(
          description: description,
          release_year: release_year,
          poster_image_url: poster_image_url,
          link: film_url,
          director: staff_info["監督"]&.join(", "),
          producers: staff_info["プロデューサー"]&.join(", "),
          distribution_company: staff_info["配給"]&.join(", "),
          original_work: staff_info["原作"]&.join(", "),
          scriptwriter: staff_info["脚本"]&.join(", "),
          photography: staff_info["撮影"]&.join(", "),
          lighting: staff_info["照明"]&.join(", "),
          art_direction: staff_info["美術"]&.join(", "),
          music: staff_info["音楽"]&.join(", "),
          editing: staff_info["編集"]&.join(", "),
          costumes: staff_info["衣装"]&.join(", "),
          makeup_artists: staff_info["ヘアメイク"]&.join(", "),
          casts: casts.join(", ")
        )
      end

      # 次のページがあるか確認
      next_page_link = index_doc.css('.pagination a.next').first
      break unless next_page_link

      start_page = next_page_link.attr("href").match(/START=(\d+)/)[1].to_i
    end
  end
end





require 'open-uri'
require 'nokogiri'

namespace :films do
  desc "Scrape and save latest films"
  task scrape_300: :environment do
    base_url = 'http://jfdb.jp'
    index_url = "#{base_url}/search/title?ORDER=RELE_A" # 古い公開日から順に並べる

    # データを取得
    index_doc = Nokogiri::HTML(URI.open(index_url))

    films_to_save = []

    index_doc.css('.search-result-item').each do |item|
      break if films_to_save.length >= 5

      title = item.css('.list-title a').text.strip
      description = item.css('.title-description').text.strip
      release_year = item.css('small.prod_year').text.strip.match(/\((\d+)\)/)[1].to_i # 公開年を取得

      poster_image_url = item.css('.list-img-top img').attr('src').value
      link = item.css('.list-title a').attr('href').value
      film_url = "#{base_url}#{link}"

      # 映画の詳細ページにアクセス
      detail_doc = Nokogiri::HTML(URI.open(film_url))

      # キャスト情報を取得して保存
      cast_items = detail_doc.css('.title-cast dd')
      cast_names = cast_items.map { |cast| cast.text.strip.split(',').map(&:strip) }.flatten.uniq

      # スタッフ情報を取得して保存
      staff_items = detail_doc.css('.title-staff li')
      staff_names = staff_items.map { |staff| staff.text.strip.split(' ── ')[0] }

      # データベースに保存
      film = Film.create!(
        title: title,
        description: description,
        release_year: release_year,
        poster_image_url: poster_image_url,
        link: film_url
      )

      # キャスト情報を保存
      cast_names.each do |cast_name|
        film.casts.create!(name: cast_name) unless cast_name.empty?
      end

      # スタッフ情報を保存
      staff_names.each do |staff_name|
        film.staffs.create!(name: staff_name) unless staff_name.empty?
      end

      films_to_save << film
    end
  end
end