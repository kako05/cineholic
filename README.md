# アプリ名
## シネホリック

# アプリ概要
## 映画検索アプリ
- 俳優や監督だけでなく、技術スタッフ名でも検索できる
- 上映中の作品一覧
- レビュー投稿

# URL
http://18.178.57.99
テストユーザー情報1 (nickname:たろう e-mail:taro@taro password:taro111)
テストユーザー情報2 (nickname:はなこ e-mail:hana@hana password:hana111)

# テスト用アカウント
- Basic認証ID :admin
- Basic認証Password :4545


# 利用方法
- 検索はサインインなしで利用可能
- ひらがな、カタカナ、漢字、英字から検索可能
- 作品をクリックすると作品の詳細が見られる
- サインインするとマイペ-ジ、レビュー投稿、お気に入り等の機能が利用可能


# アプリ開発の背景
- 自分が次に仕事一緒にするスタッフの過去作を見る時に
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

| Column             | Type   | Options                   |
| ------------------ | ------ | ------------------------- |
| nickname           | string | null: false               |
| email              | string | null: false, unique: true |
| encrypted_password | string | null: false               |


### Association

- has_many :likes
- has_many :films, through: :likes
- has_many :comments
- has_many :films, through: :comments



## films テーブル

| Column           | Type       | Options                        |
| ---------------- | ---------- | ------------------------------ |
| title            | string     | null: false                    |
| description      | text       |                                |
| release_date     | string     |                                |
| poster_image_url | string     |                                |
| link             | string     |                                |
| comment          | references | null: false, foreign_key: true |
| like             | references | null: false, foreign_key: true |


### Association

- has_many :users, through: :comments
- has_many :likes
- has_many :comments
- has_many :film_casts
- has_many :casts, through: :film_casts
- has_many :film_trailers
- has_many :trailers, through: :film_trailers



## casts テーブル

| Column | Type       | Options       |
| ------ | ---------- | ------------- |
| name   | string     |               |


### Association

- has_many :films, through: :film_casts
- has_many :film_casts



## film_casts　テーブル

| Column | Type       | Options              |
| ------ | ---------- | -------------------- |
| film   | references | foreign_key: true    |
| cast   | references | foreign_key: true    |


### Association

- belongs_to :film
- belongs_to :cast



## staffs　テーブル

| Column        | Type     | Options       |
| ------------- | -------- | ------------- |
| name          | string   |               |
| role          | string   |               |
| production    | string   |               |
| official_site | string   |               |
| text          | text     |               |


### Association

- has_many :films, through: :film_staffs
- has_many :film_staffs



## film_staffs　テーブル

| Column  | Type       | Options              |
| ------- | ---------- | -------------------- |
| film    | string     |                      |
| trailer | references | foreign_key: true    |

### Association

- belongs_to :film
- belongs_to :cast



## likes テーブル

| Column | Type       | Options                        |
| ------ | ---------- | ------------------------------ |
| user   | references | null: false, foreign_key: true |
| film   | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :film
- belongs_to :comment



## comments テーブル

| Column   | Type       | Options                        |
| -------- | ---------- | ------------------------------ |
| text     | text       |                                |
| score    | integer    | null: false                    |
| user     | references | null: false, foreign_key: true |
| film     | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :film


# 開発環境
## フロントエンド
- HTML,SCSS,JavaScript

## バックエンド
- Ruby, Ruby on Rails7.0.0

## データベース
- MySQL5.7.44

## ソース管理
- GitHub,GitHub Desktop

## デプロイ
- AWS(EC2)