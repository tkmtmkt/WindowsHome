WindowsHome
===========
Windowsのユーザホームディレクトリに置く環境設定用のファイルです。
PowerShellのプロファイル設定をメインにしています。

使い方
------
リポジトリのルートがWindowsのユーザホームディレクトリになっています。
以下の手順でホームディレクトリをgitリポジトリとして初期化します。

    cd $home
    git init

GitHubからファイルを取得します。

    git remote add origin https://github.com/tkmtmkt/WindowsHome.git
    git pull
    git branch --set-upstream master origin/master
    git checkout master

サブモジュールを取得します。

    git submodule init
    git submodule update

ホームディレクトリ以下の管理対象外のファイルを除外します。
（リポジトリのルートがホームディレクトリになるので.gitignoreはグローバル
設定になってしまうため、リポジトリ内の設定ファイルを変更する。）

    @"
    *
    !README.md
    !Documents/WindowsPowerShell/profile.ps1
    !posh.bat
    !.bashrc
    !.vim/*
    !_vimrc
    !_gvimrc
    !.gitconfig
    !.gitignore
    !.gitmodules
    "@ | Out-File "$home/.git/info/exclude" -encoding OEM -append


設定内容
--------
コマンドラインツールのパス設定、コンソールの色設定、日常作業で使用する関数を定義しています。

### ツール（基本）
"$Env:HOME\tool"フォルダに基本的なツールを置きます。

* アーカイバ：
  [7-ZIP](http://sevenzip.sourceforge.jp/)

* エディタ：
  [KaoriYa](http://www.kaoriya.net/)

* 差分ツール：
  [WinMerge](http://www.geocities.co.jp/SiliconValley-SanJose/8165/winmerge.html)

* リモート接続：
  [Tera Term](http://sourceforge.jp/projects/ttssh2/),
  [WinSCP](http://winscp.net/eng/docs/lang:jp),
  [RealVNC](http://www.realvnc.com/)

* システム管理：
  [SysinternalsSuite](http://technet.microsoft.com/ja-jp/sysinternals/bb842062.aspx),
  [Log Parser](http://technet.microsoft.com/ja-jp/scriptcenter/dd919274.aspx),
  [Windows Server 2003 Resource Kit Tools](http://www.microsoft.com/en-us/download/details.aspx?id=17657),
  [Windows Server 2003 Service Pack 2 32-bit Support Tools](http://www.microsoft.com/en-us/download/details.aspx?id=15326)

* 構成管理：
  [Fossil](http://www.fossil-scm.org/)

* データベース：
  [SQLite](http://www.sqlite.org/)


### ツール（オプション）
"$Env:HOME\apps"フォルダに追加のツールを置きます。

* 構成管理：
  [msysgit](http://code.google.com/p/msysgit/downloads/list),
  [Subversion for Windows](http://sourceforge.net/projects/win32svn/),
  [Veracity](http://veracity-scm.com/)

* データベース：
  [MongoDB](http://www.mongodb.org/)

* プログラミング：
  [Java SE](http://www.oracle.com/technetwork/java/javase/downloads/index.html),
  [Scala](http://www.scala-lang.org/),
  [Python](http://www.python.org/),
  [Jython](http://www.jython.org/),
  [Clojure](http://clojure.org/),
  [RubyInsaller for Windows](http://rubyinstaller.org/)

* ビルド管理：
  [Apache Ant](http://ant.apache.org/),
  [Apache Maven](http://maven.apache.org/)


### 関数定義

* memo - 作業記録用のテキストファイルを開きます。
* last - ひとつ前の作業記録用のテキストファイルを開きます。
* grep - UNIXのgrepぽいもの。
* cap - クリップボード内の画像を`work:images\img000.png`に保管します。
* Get-Hash - ファイルのMD5チェックサムを計算します。
* Get-Assemblies - PowerShellセッションにロード済みのアセンブリを表示します。
* sbt-init - sbt (simple build tool)の初期プロジェクトを作成します。

<!-- vim: set ts=4 sw=4 et:-->
