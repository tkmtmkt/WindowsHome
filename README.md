WindowsPowerShell
=================
PowerShellの作業環境設定用のファイルです。

使い方
------
リポジトリのクローンをプロファイルの場所に置くだけです。

    git clone https://github.com/tkmtmkt/WindowsPowerShell.git (Split-Path $PROFILE)


設定内容
--------
コマンドラインツールのパス設定、コンソールの色設定、日常作業で使用する関数を定義しています。

### ツール（基本）
"$Home\tool"フォルダに基本的なツールを置きます。

* アーカイバ：
  [7-ZIP](http://sevenzip.sourceforge.jp/)

* エディタ：
  [KaoriYa](http://www.kaoriya.net/)

* 差分ツール：
  [WinMerge](http://winmerge.org/?lang=ja)

* リモート接続：
  [Tera Term](http://sourceforge.jp/projects/ttssh2/),
  [WinSCP](http://winscp.net/eng/docs/lang:jp),
  [RealVNC](http://www.realvnc.com/)

* システム管理：
  [SysinternalsSuite](http://technet.microsoft.com/ja-jp/sysinternals/bb842062.aspx),
  [Log Parser](http://technet.microsoft.com/ja-jp/scriptcenter/dd919274.aspx)

* 構成管理：
  [Fossil](http://www.fossil-scm.org/)

* データベース：
  [SQLite](http://www.sqlite.org/)

### ツール（オプション）
"$Home\apps"フォルダに追加のツールを置きます。

* 構成管理：
  [msysgit](http://code.google.com/p/msysgit/downloads/list),
  [Subversion for Windows](http://sourceforge.net/projects/win32svn/),
  [Veracity](http://veracity-scm.com/)

* データベース：
  [MongoDB](http://www.mongodb.org/)

* プログラミング：
  [Java SE](http://www.oracle.com/technetwork/java/javase/downloads/index.html),
  [Scala](http://www.scala-lang.org/),
  [Jython](http://www.jython.org/),
  [Clojure](http://clojure.org/),
  [RubyInsaller for Windows](http://rubyinstaller.org/)

* ビルド管理：
  [Apache Ant](http://ant.apache.org/),
  [Apache Maven](http://maven.apache.org/)

### 関数定義

* memo
* Get-Hash
* Get-Assemblies

<!-- vim: set ts=4 sw=4 et:-->
