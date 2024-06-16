# アプリ名
## シネホリック

# アプリ概要
## 映画検索アプリ
- 俳優や監督だけでなく、技術スタッフ名でも検索できる
- 上映中の作品一覧
- レビュー投稿

# URL
http://18.178.57.99

- テストユーザー情報1 (nickname:たろう e-mail:taro@taro password:taro111)
- テストユーザー情報2 (nickname:はなこ e-mail:hana@hana password:hana111)

# テスト用アカウント
- Basic認証ID :admin
- Basic認証Password :4545


# 利用方法
- 検索はユーザー登録なしで利用可能
- ひらがな、カタカナ、漢字、英字から検索可能
- 上映作品を最新順で見ることが可能
- 作品をクリックすると作品の詳細が見られ、公式ページに遷移することも可能
- サインインするとマイページ、レビュー投稿、お気に入り等の機能が利用可能


# アプリ開発の背景
- 映画スタッフをしていたときに、次に一緒に仕事をするスタッフの過去作が見たいとき、
  スタッフ名から検索できる場所が少なく、探すのが大変だった
- 映画館で、観客が上映中の作品を担当した技術スタッフや、
  映画賞などで受賞した技術スタッフについて
  他にどんな作品に携わっているんだろう話している場面を何度か見た
- 検索方法がなくて諦めている人がいる現状から、アプリ開発をする意義を感じた

# UIデザイン

<img width="633" alt="シネホリック" src="https://github.com/kako05/cineholic/assets/167449348/4f237d27-3bfb-4f20-8959-6ebf321a6e59">


# ER図

![cineholic](https://github.com/kako05/cineholic/assets/167449348/f3a50d4c-8cbc-4c5e-92c9-c625994b4341)



## users テーブル

| Column             | Type   | Options      |
| ------------------ | ------ | ------------ |
| nickname           | string | null: false  |
| email              | string | null: false  |
| encrypted_password | string | null: false  |


### Association

- has_many :comments
- has_many :likes, dependent: :destroy
- has_many :like_films, through: :likes, source: :film



## films テーブル

| Column           | Type       | Options       |
| ---------------- | ---------- | ------------- |
| title            | text       |               |
| description      | text       |               |
| release_date     | string     |               |
| poster_image_url | string     |               |
| link             | string     |               |


### Association

- has_many :film_casts, dependent: :destroy
- has_many :casts, through: :film_casts
- has_many :film_trailers, dependent: :destroy
- has_many :trailers, through: :film_trailers
- has_many :comments, dependent: :destroy
- has_many :likes, dependent: :destroy
- has_many :likers, through: :likes, source: :user



## casts テーブル

| Column | Type       | Options       |
| ------ | ---------- | ------------- |
| name   | string     |               |


### Association

- has_many :films, through: :film_casts
- has_many :film_casts, dependent: :destroy



## film_casts テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| film   | references | null: false, foreign_key: true |
| cast   | references | foreign_key: true              |


### Association

- belongs_to :film
- belongs_to :cast



## trailers テーブル

| Column        | Type     | Options       |
| ------------- | -------- | ------------- |
| name          | string   |               |
| role          | string   |               |
| production    | text     |               |
| official_site | string   |               |
| text          | text     |               |


### Association

- has_many :films, through: :film_trailers
- has_many :film_trailers, dependent: :destroy



## film_trailers 　テーブル

| Column  | Type       | Options                        |
| ------- | ---------- | ------------------------------ |
| film    | references | null: false, foreign_key: true |
| trailer | references | foreign_key: true              |

### Association

- belongs_to :film
- belongs_to :trailer



## likes テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| user   | references | null: false, foreign_key: true |
| film   | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :film



## comments テーブル

| Column   | Type     | Options      |
| -------- | -------- | ------------ |
| comment  | text     |              |
| user     | integer  | null: false  |
| film     | integer  | null: false  |

### Association

- belongs_to :user
- belongs_to :film


# 開発環境
## フロントエンド
- HTML,CSS,JavaScript

## バックエンド
- Ruby3.2.0, Ruby on Rails7.0.0

## 動画編集
- PremierePro24.4.1

## データベース
- MySQL5.7.44

## ソース管理
- GitHub,GitHub Desktop

## デプロイ
- AWS(EC2)