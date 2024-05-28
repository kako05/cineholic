require "open-uri"
require "nokogiri"

namespace :films do
  desc "Scrape and save latest films"
  task scrape_6787: :environment do
    base_url = "http://jfdb.jp"
    start_page =20
    page_size = 272

    loop do
      index_url = "#{base_url}/search/title?ORDER=RELE_D&PAGE=#{start_page}" # 公開日で降順に並べ替え

      begin
        # データを取得
        index_doc = Nokogiri::HTML(URI.open(index_url))
      rescue => e
        puts "インデックスページのスクレイピング中にエラーが発生しました: #{e.message}"
        return
      end

      # 1ページあたり300件を処理
      index_doc.css('.search-result-item').each_with_index do |item, i|
        break if i >= page_size

        title = item.css('.list-title a').text.strip

        # タイトルから公開年を除去
        title = title.gsub(/\s*\(\d{4}\)$/, '').strip

        # タイトルが空の場合はスキップ
        next if title.empty?

        # 映画レコードを検索または作成
        film = Film.find_or_create_by(title: title)

        description = item.css('.title-description').text.strip
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

        release_date = detail_doc.at('dt:contains("公開日") + dd').text.strip

        # キャスト情報を取得して保存
        cast_items = detail_doc.css('.title-cast dd')
        cast_names = cast_items.map { |cast| cast.text.strip.split(',').map(&:strip) }.flatten.uniq

        cast_names.each do |cast_name|
          cast = Cast.find_or_create_by(name: cast_name)
          FilmCast.find_or_create_by(film: film, cast: cast)
        end

        # スタッフ情報を抽出して保存
        detail_doc.css('.title-detail h2').each do |heading|
          case heading.text.strip
          when "【監督】"
            director_names = heading.next_element.css('a').map(&:text).map(&:strip)
            director_names.each do |director_name|
              director = Trailer.find_or_create_by(name: director_name, role: "監督")
              FilmTrailer.find_or_create_by(film: film, trailer: director)
            end
          when "【プロデューサー】"
            producer_items = heading.next_element.css('li')
            producer_items.each do |producer_item|
              producer_name = producer_item.css('a').text.strip
              role = "プロデューサー"
              trailer = Trailer.find_or_create_by(name: producer_name, role: role)
              FilmTrailer.find_or_create_by(film: film, trailer: trailer)
            end
          when "【スタッフ】"
            trailer_list = heading.next_element.css('li')
            trailer_list.each do |trailer_item|
              trailer_name = trailer_item.css('a').text.strip
              role = trailer_item.css('span').text.strip.split(/─|ー/)[2].strip if trailer_item.text.strip.split(/─|ー/).length > 2

              # 録音/音響および美術/美術監督の役割を統合
              role = "録音" if ["録音", "音響"].include?(role)
              role = "美術" if ["美術", "美術監督"].include?(role)
              role = "衣装" if ["衣装", "衣裳", "スタイリスト"].include?(role)
        
              trailer = Trailer.find_or_create_by(name: trailer_name, role: role)
              FilmTrailer.find_or_create_by(film: film, trailer: trailer)
            end
          when "【製作会社】"
            production = heading.next_element.text.strip
            trailer = Trailer.find_or_create_by(production: production)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          when "【公式サイト】"
            official_site_url = heading.next_element.css('a').attr('href').value
            trailer = Trailer.find_or_create_by(official_site: official_site_url)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          when "【解説】"
            text = heading.next_element.text.strip
            trailer = Trailer.find_or_create_by(text: text)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          end
        end
        

        # 映画データを更新
        film.update(
          description: description,
          release_date: release_date,
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