# アプリ名
## シネホリック

# アプリ概要
## 映画検索アプリ
- 俳優や監督だけでなく、技術スタッフ名でも検索できる
- 上映中の作品一覧
- レビュー投稿

# URL
https://cineholic.onrender.com

# テスト用アカウント
- Basic認証ID :
- Basic認証Password :


# 利用方法
- 検索はサインインなしで利用可能
- サインインするとマイペ-ジ、レビュー投稿、お気に入り等の機能が利用可能

# アプリ開発の背景
- 自分が次に仕事一緒にするスタッフの過去作を見る時に、探すのが大変だった
- 映画館で、観客が技術スタッフについて話している場面を何度か見た
  検索方法がなくて諦めている人がいると感じた

  
# テーブル設計

## users テーブル

| Column             | Type   | Options                   |
| ------------------ | ------ | ------------------------- |
| nickname           | string | null: false               |
| email              | string | null: false, unique: true |
| encrypted_password | string | null: false               |



### Association

- has_many :films, through: :comments
- has_many :likes
- has_many :comments



## films テーブル

| Column      | Type       | Options                        |
| ----------- | ---------- | ------------------------------ |
| title       | string     | null: false                    |
| text        | text       | null: false                    |
| genre_id    | integer    | null: false                    |
| release     | string     | null: false                    |
| user        | references | null: false, foreign_key: true |

### Association

- has_many :users, through: :comments
- has_many :likes
- has_many :comments



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
| genre_id | integer    |                                |
| score    | integer    | null: false                    |
| user     | references | null: false, foreign_key: true |
| film     | references | null: false, foreign_key: true |

### Association

- belongs_to :user
- belongs_to :film