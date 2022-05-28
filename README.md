
# 政治資金収支報告書アーカイブシステム
- 公財）政治資金センターで管理する政治資金収支報告書の公開システム

# 前提
- Dockerを使ってます。


# 環境構築
- ターミナル操作
  - git clone
  - Dockerコンテナを立ち上げる
  ```
  $ docker-compose build
  $ docker-compose up -d
  ```
  - 環境変数をセットする
    - /.envファイルを準備する
    ```
    $ cp .env.sample .env
    ```
  - データベース構築
  ```
  $ docker-compose exec web rails db:create
  $ docker-compose exec web rails db:migrate
  ```
- 動作確認
  - http://localhost:3000/ にアクセス

- DBのダンプ・レストアのコマンド例
  ```
    docker-compose exec db pg_dump -U postgres app_development > db/dump_YYYYMMDD.sql
  ```
  ```
    cat db/dump_YYYYYMMDD.sql | docker-compose exec -T db psql -U postgres app_development
  ```
