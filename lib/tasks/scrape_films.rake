require "open-uri"
require "nokogiri"

namespace :films do
  desc "Scrape and save latest films"
  task scrape_300: :environment do
    base_url = "http://jfdb.jp"
    start_page = 1 # ページ1から開始
    page_size = 300 # 1ページあたり300件を処理

    loop do
      index_url = "#{base_url}/search/title?ORDER=RELE_D&START=#{start_page}" # 公開日で降順に並べ替え

      begin
        # データを取得
        index_doc = Nokogiri::HTML(URI.open(index_url))
      rescue => e
        puts "インデックスページのスクレイピング中にエラーが発生しました: #{e.message}"
        return
      end

      # 1ページあたりpage_size件を処理
      index_doc.css('.search-result-item').each_with_index do |item, i|
        break if i >= page_size

        title = item.css('.list-title a').text.strip

        # タイトルが空の場合はスキップ
        next if title.empty?

        # 映画レコードを検索または作成
        film = Film.find_or_create_by(title: title)

        description = item.css('.title-description').text.strip
        release_year_element = item.css('small.prod_year').first
        release_year = item.css('small.prod_year').text.strip.match(/\((\d+)\)/)[1].to_i # 公開年を取得

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

        # キャスト情報を取得して保存
        cast_items = detail_doc.css('.title-cast dd')
        cast_names = cast_items.map { |cast| cast.text.strip.split(',').map(&:strip) }.flatten.uniq

        cast_names.each do |cast_name|
          cast = Cast.find_or_create_by(name: cast_name)
          FilmCast.find_or_create_by(film: film, cast: cast)
        end

        # スタッフ情報を抽出して保存
        staff_info = {}
        detail_doc.css('.title-detail h2').each do |heading|
          # タイトルが「スタッフ」であるh2要素の次の兄弟要素のul内のli要素を取得
          if heading.text.strip == "【スタッフ】"
            staff_list = heading.next_element.css('li')
            staff_list.each do |staff_item|
              staff_name = staff_item.css('a').text.strip
              role = staff_item.text.strip.split(/─|ー/)[1].strip

              # 録音/音響および美術/美術監督の役割を統合
              role = "録音・音響" if ["録音", "音響"].include?(role)
              role = "美術" if ["美術", "美術監督"].include?(role)
              role = "衣装" if ["衣装", "衣裳", "スタイリスト"].include?(role)

              staff = Staff.find_or_create_by(name: staff_name)
              staff.update(role: role)
              FilmStaff.find_or_create_by(film: film, staff: staff)
            end
          end
        end

        # 映画データを更新
        film.update(
          description: description,
          release_year: release_year,
          poster_image_url: poster_image_url,
          link: film_url,
        )
      end

      # 次のページがあるか確認
      next_page_link = index_doc.css('.pagination a.next').first
      break unless next_page_link

      start_page = next_page_link.attr("href").match(/START=(\d+)/)[1].to_i
    end
  end
end