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