> [!NOTE]
フォーク元にあったアフィリエイトリンクは削除しています

# Qiita
[【学内向け？】skrsqlの環境構築 〜VirtualBoxアレルギーのあなたへ〜](https://qiita.com/yuu2461/items/6dc6a8e403cbfb17dadb)

# このリポジトリは?

株式会社フレアリンク様が出版されている「[スッキリわかるSQL入門第4版](https://sukkiri.jp/books/sukkiri_sql4)」購入者が利用できるダウンロードリソースを用いて、ローカルの環境でSQLの練習をおこなうツールのひとつです。
[dokoQL](http://dokoql.com)が使えればGUIでそれなりに操作しやすいかもしれませんが、スタンドアロンで試したいという需要もあると思って作成しました。

特に学校の授業で一斉に用いる場合、dokoQL様に同時アクセスによる負荷が懸念されるので、初回のローカルセットアップ以降は外部ネットワークがほぼ不要となる本ツールはそれなりの需要があるかと思い、公開いたします。
作者の個人的な趣味・嗜好により、CLIしかありません。

# 動作環境

動作環境としては以下を想定しています。

- 書籍 [スッキリわかるSQL入門第3版](https://sukkiri.jp/books/sukkiri_sql4) ※必須条件、お持ちでない方は使えません
- Ubuntu Linux22.04LTS(サーバー版)
     - postgresql-10パッケージによるサーバー
- もしくはDocker環境(イメージ利用)



PostgreSQLに関しては、利用者が以下の条件を満たしていることを前提としています。

- 使用ユーザーがデータベース作成権限を保有すること(`createuser -d`など)
- 使用ユーザーが(少なくともデータベース名Canについて)パスワード入力無しで`createdb`/`dropdb`できること[^1]

[^1]: ファイル `~/.pgpass` を作成し、 `locahost:5432:Can:ユーザー名:パスワード` と入れて、パーミッションを0600にすればたいていOK

# インストール・アンインストール

インストールの際に、環境チェックを行ってからインストールを行います。
まず、

    $ make

としてみてください、動作チェックを行い、必要なソースをダウンロードしてきます。

エラーが出なければ、

    $ sudo make install

としてインストールしてください。

アンインストール、クリーニングについては、

    $ sudo make uninstall
    $ make clean

を用意しています。

# 基本的な使い方

テキストに含まれているリストなどの番号を使って行います。
テキストにて「リスト4-10」(List 4-10)とあれば、

  $ list 4 10

と入れてみてください、DBの下準備が行われた上で`psql`コマンドが実行されて入力可能になります。
ただし現時点ではmacOS上での都合か、`psql`上で**日本語がうまく入力できないことがある**ため、**行編集機能を無効化**しています[^2]。

[^2]: まっとうな対応方法がわかったら修正を加える予定です。

他のツールとしては、

- q: 問題(問題番号を引数に)
- can: できるようになったことのまとめ(章番号を引数に)
- drill: 付録に含まれる問題用

があります。

# Dockerイメージ版

- [densukest/skrsql](https://hub.docker.com/r/densukest/skrsql)

[![.github/workflows/ci.yml](https://github.com/densuke/skrsql/actions/workflows/ci.yml/badge.svg)](https://github.com/densuke/skrsql/actions/workflows/ci.yml)

```
$ docker run -d --name skrsql densukest/skrsql:v3
$ docker exec -it -u sql skrsql コマンド 引数...
```

Dockerイメージの動作は以下の環境で確認しております。

- Linux/amd64(Docker Desktop内)
- Linux/arm64
    - Ubuntu Linux 22.04 on Raspberry Pi
    - 上記環境で動くdocker engineおよびpodman
- macOS Ventura上でのDocker Desktop
    - ごめんなさい、Intel版のみです

M1/M2 macOS上でのDocker Desktopによる検証はできておりませんが、仕組み上Linux/arm64なRaspbery Piで動くでしょうから問題無いと思ってます。
どなたかM2 macBook(Memory 16GB- & US keyboard)をお恵みいただければ検証いたしますが、今はなんともです。

`tools/skr` コマンドによりコンテナの制御や各コマンドの呼び出しが可能ですが、諸事情により`docker`コマンドではなく[podman](https://podman.io/)を使っております。

# ライセンス、再配布規定について

このコードについてはGPL3といたします。ただしインストール時にダウンロードしている`sukkiri-sql3-codes.zip`については、以下の点にご注意ください。

- ファイルの内容自体はCreative Commons BY-SA 4.0に準拠しています(そう記載されています[^3])
- ただしファイルの利用は書籍「[スッキリわかるSQL入門第3版](https://books.rakuten.co.jp/rb/17018590/)」を持っている方のみとされています(書籍特典という扱いのため)。

[^3]: [LICENSE.txt](https://github.com/miyabilink/sukkiri-sql3-codes/blob/main/LICENSE.txt)
