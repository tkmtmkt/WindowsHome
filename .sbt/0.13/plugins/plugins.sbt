//sbtコンソール内でgitコマンドを使用可能にする。
addSbtPlugin("com.typesafe.sbt" % "sbt-git" % "0.6.3")

//sbtコンソールでAPIマニュアルを参照可能にする。
addSbtPlugin("com.eed3si9n" % "sbt-man" % "0.1.1")

//ローカルリポジトリとキャッシュからプロジェクトの配布物を削除する。
addSbtPlugin("com.eed3si9n" % "sbt-dirty-money" % "0.1.0")

//ソースファイルの統計情報を表示する。
addSbtPlugin("com.orrsella" % "sbt-stats" % "1.0.6-SNAPSHOT")

// vim: set ts=2 sw=2 et:
