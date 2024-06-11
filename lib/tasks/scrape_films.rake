require 'open-uri'
require 'nokogiri'

namespace :films do
  desc 'Scrape and save latest films'
  task scrape_6787: :environment do
    base_url = 'http://jfdb.jp'
    page_size = 25
    max_pages = 130

    (91..max_pages).each do |page_number|
      sleep 1
      index_url = "#{base_url}/search/title?ORDER=RELE_D&PAGE=#{page_number}" # 公開日で降順に並べ替え
      puts "Fetching movies from page #{page_number}: #{index_url}"
      begin
        index_doc = Nokogiri::HTML(URI.open(index_url))
      rescue StandardError => e
        puts "インデックスページのスクレイピング中にエラーが発生しました#{page_number}: #{e.message}"
        next
      end
      movie_count = 0
      index_doc.css('.search-result-item').each_with_index do |item, i|
        break if i >= page_size

        title = item.css('.list-title a').text.strip
        title = title.gsub(/\s*\(\d{4}\)$/, '').strip
        next if title.empty?

        # カタカナ変換を削除し、全角を半角に変換する部分だけにする
        title = title.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
        title = title.downcase # キーワードを小文字に変換
        film = Film.find_or_create_by(title: title)

        description = item.css('.title-description').text.strip
        description = description.gsub(/\b(?:https?|ftp):\/\/[-\w+&@#\/%?=~|$!_:;,.]*[-\w+&@#\/%?=~|$!_:;,.]/, '')
        description = description.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
        description = description.downcase

        poster_image_url = item.css('.list-img-top img').attr('src').value
        poster_image_url = poster_image_url.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
        link = item.css('.list-title a').attr('href').value
        film_url = "#{base_url}#{link}"

        begin
          detail_doc = Nokogiri::HTML(URI.open(film_url))
        rescue StandardError => e
          puts "映画「#{title}」の詳細ページのスクレイピング中にエラーが発生しました: #{e.message}"
          next
        end

        release_date = detail_doc.at('dt:contains("公開日") + dd').text.strip
        release_date = release_date.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)

        cast_items = detail_doc.css('.title-cast dd')
        cast_names = cast_items.map { |cast| cast.text.strip.split(',').map(&:strip) }.flatten.uniq
        cast_names.each do |cast_name|
          cast_name = cast_name.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
          cast = Cast.find_or_create_by(name: cast_name)
          FilmCast.find_or_create_by(film: film, cast: cast)
        end

        detail_doc.css('.title-detail h2').each do |heading|
          case heading.text.strip
          when '【監督】'
            director_names = heading.next_element.css('a').map(&:text).map(&:strip)
            director_names.each do |director_name|
              director_name = director_name.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
              director = Trailer.find_or_create_by(name: director_name, role: '監督')
              FilmTrailer.find_or_create_by(film: film, trailer: director)
            end
          when '【プロデューサー】'
            producer_items = heading.next_element.css('li')
            producer_items.each do |producer_item|
              producer_name = producer_item.css('a').text.strip
              role = 'プロデューサー'
              producer_name = producer_name.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
              trailer = Trailer.find_or_create_by(name: producer_name, role: role)
              FilmTrailer.find_or_create_by(film: film, trailer: trailer)
            end
          when '【スタッフ】'
            trailer_list = heading.next_element.css('li')
            trailer_list.each do |trailer_item|
              trailer_name = trailer_item.css('a').text.strip
              role = trailer_item.css('span').text.strip.split(/─|ー/)[2].strip if trailer_item.text.strip.split(/─|ー/).length > 2
              role = '録音' if %w[録音 音響].include?(role)
              role = '美術' if %w[美術 美術監督].include?(role)
              role = '衣装' if %w[衣装 衣裳 スタイリスト].include?(role)
              trailer = Trailer.find_or_create_by(name: trailer_name, role: role)
              FilmTrailer.find_or_create_by(film: film, trailer: trailer)
            end
          when '【製作会社】'
            production = heading.next_element.text.strip
            production = production.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
            trailer = Trailer.find_or_create_by(production: production)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          when '【公式サイト】'
            official_site_url = heading.next_element.css('a').attr('href').value
            official_site_url = official_site_url.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
            trailer = Trailer.find_or_create_by(official_site: official_site_url)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          when '【解説】'
            text = heading.next_element.text.strip
            text = text.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
            trailer = Trailer.find_or_create_by(text: text)
            FilmTrailer.find_or_create_by(film: film, trailer: trailer)
          end
        end

        description = description.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)
        poster_image_url = poster_image_url.tr('ａ-ｚＡ-Ｚａ-ｚ', 'a-zA-Z').unicode_normalize(:nfkc)

        film.update(
          description: description,
          release_date: release_date,
          poster_image_url: poster_image_url,
          link: film_url
        )
        movie_count += 1
      end
      puts "Movies fetched from page #{page_number}: #{movie_count}"
      next_page_link = index_doc.css('.pagination li.page-item').first
      break unless next_page_link

      index_url = "#{base_url}#{next_page_link.attr('href')}"
    end
  end
end