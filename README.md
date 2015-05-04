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


設定内容
--------
コマンドラインツールのパス設定、コンソールの色設定、日常作業で使用する関数を定義しています。

### ツール（基本）
`$TOOLDIR="$Env:PUBLIC\tool"`フォルダに基本的なツールを置きます。

* アーカイバ：
  [7-ZIP](http://sevenzip.sourceforge.jp/)

* エディタ：
  [KaoriYa](http://www.kaoriya.net/),
  [MarkDown#Editor](http://hibara.org/software/markdownsharpeditor/),
  [FavBinEdit](http://tech2assist.web.fc2.com/FavBinEdit/),
  [zeeta](https://sites.google.com/site/zeetahp/)

* 差分ツール：
  [WinMerge](http://www.geocities.co.jp/SiliconValley-SanJose/8165/winmerge.html)

* リモート接続：
  [Tera Term](http://sourceforge.jp/projects/ttssh2/),
  [WinSCP](http://winscp.net/eng/docs/lang:jp),
  [RealVNC](http://www.realvnc.com/),
  [ConEmu](http://sourceforge.jp/projects/conemu/)

* システム管理：
  [SysinternalsSuite](http://technet.microsoft.com/ja-jp/sysinternals/bb842062.aspx),
  [Windows Server 2003 Resource Kit Tools](http://www.microsoft.com/en-us/download/details.aspx?id=17657),
  [Windows Server 2003 Service Pack 2 32-bit Support Tools](http://www.microsoft.com/en-us/download/details.aspx?id=15326),
  [Intel vPro Technology Modules for Microsoft Windows PowerShell](http://www.intel.com/content/www/us/en/remote-support/vpro-technology-module-for-microsoft-windows-powershell.html),
  [Log Parser](http://technet.microsoft.com/ja-jp/scriptcenter/dd919274.aspx),
  [LogExpert](http://www.log-expert.de/)

* 構成管理：
  [Fossil](http://www.fossil-scm.org/)

* データベース：
  [SQLite](http://www.sqlite.org/)


### ツール（オプション）
`$APPSDIR="$Env:PUBLIC\apps"`フォルダに追加のツールを置きます。

* 構成管理：
  [msysgit](https://github.com/msysgit/msysgit/releases),
  [Subversion for Windows](http://sourceforge.net/projects/win32svn/),
  [Veracity](http://veracity-scm.com/)

* データベース：
  [MongoDB](http://www.mongodb.org/)

* プログラミング：
  [Java SE](http://www.oracle.com/technetwork/java/javase/downloads/index.html),
  [Scala](http://www.scala-lang.org/),
  [Groovy](http://groovy.codehaus.org/),
  [Python](http://www.python.org/),
  [Jython](http://www.jython.org/),
  [Clojure](http://clojure.org/),
  [checkstyle](http://checkstyle.sourceforge.net/),
  [findbugs](http://findbugs.sourceforge.net/),
  [jacoco](http://www.eclemma.org/jacoco/),
  [pmd](http://pmd.sourceforge.net/),
  [javancss](http://www.kclee.de/clemens/java/javancss/),
  [junit](http://junit.org/),
  [mockito](http://mockito.org/),
  [RubyInsaller for Windows](http://rubyinstaller.org/)


* ビルド管理：
  [Apache Ant](http://ant.apache.org/),
  [Apache Ivy](http://ant.apache.org/ivy/),
  [Apache Maven](http://maven.apache.org/),
  [gradle](http://www.gradle.org/),
  [sbt](http://www.scala-sbt.org/),
  [leiningen](http://leiningen.org/)

* その他ツール：
  [Pleiades - Eclipse プラグイン日本語化プラグイン](http://mergedoc.sourceforge.jp/),
  [GNU GLOBAL](http://www.gnu.org/software/global/),
  [pandoc](https://github.com/jgm/pandoc/releases)


### 関数定義

* memo - 作業記録用のテキストファイルを開きます。
* last - ひとつ前の作業記録用のテキストファイルを開きます。
* grep - UNIXのgrepぽいもの。
* cap - クリップボード内の画像を`work:images\img000.png`に保管します。
* md5sum - ファイルのMD5チェックサムを計算します。
* sha1sum - ファイルのSHA1チェックサムを計算します。
* Get-Assemblies - PowerShellセッションにロード済みのアセンブリを表示します。


その他
------

### 端末フォント設定

* [プログラミング用フォント Ricty](http://save.sys.t.u-tokyo.ac.jp/~yusa/fonts/ricty.html)
* [MacType](https://code.google.com/p/mactype/)


### TeraTerm設定

TERATERM.INIを編集してメニューの日本語化、ウィンドウサイズ、色を設定する。

    UILanguageFile=lang\Japanese.lng
    TerminalSize=120,40
    VTFont=Ricty,0,-16,128

罫線が文字化けするのでUNICODEからDEC文字への変換対象から外す。

    UnicodeToDecSpMapping=2


### WinMerge設定

7z.dllをWinMergeフォルダにコピーして、アーカイブサポートを有効にする。
※バージョン9.20をコピーすること。9.22は認識しない。

    cp $TOOLDIR\7-Zip\7z.dll $WINMERGE_HOME


### Resource Kit Tools

    tool:
    cd \arch

    zip x -otmp rktools.exe
    zip x -orktools tmp\rktools.msi
    mv rktools ..
    rm tmp


### Support Tools 設定

    tool:
    cd \arch

    zip x -oSUPPORT support.cab
    mv SUPPORT ..


### fossil設定

リポジトリファイルを作成する。

    fossil init REPO_FILE

ユーザを作成する。

    fossil user new USERNAME -R REPO_FILE

管理者権限を付与する。

    fossil user capabilities USERNAME -R REPO_FILE

ユーザパスワードを変更する。

    fossil user password USERNAME -R REPO_FILE

作業ディレクトリを作成する。

    fossil open REPO_FILE

作業ディレクトリに以下のファイルが作成される。（ファイルはsqlite3データベース）

    _FOSSIL_

作業ディレクトリのリポジトリ位置情報はsqlで参照する。

    sql _FOSSIL_
    .mode line
    select * from vvar;

参考：グローバル設定情報は以下のファイルに保管される。（ファイルはsqlite3データベース）
    $Env:LOCALAPPDATA\_fossil


### git設定

日本語対応設定

    arch:
    cd \arch\git

    zip e less-418-utf8.zip less-418-utf8-bin\less.exe
    mv less.exe $GIT_HOME/bin

    zip e nkfwin.zip 'vc2005\win32(98,Me,NT,2000,XP,Vista,7)Windows-31J\nkf32.exe'
    mv nkf32.exe $GIT_HOME\bin

git-bashのvimパスを変更

    @"
    #!/bin/sh
    exec /c/Users/Public/tool/vim/vim "$@"
    "@ | sc $GIT_HOME\bin\vim

    cp $GIT_HOME\bin\vim $GIT_HOME\bin\vi

設定ファイルを編集する。

    git config --global -e


### Subversion設定

設定ファイルを編集する。

    gvim $Env:APPDATA\Subversion\config


### Veracity設定

BTSサーバを起動するために必要な設定を行う。

    vv config set server/files $VERACITY_HOME\server_files

リポジトリを作成する。(方法1)

    vv repo new REPO_NAME
    vv checkout REPO_NEM WORK_DIR

リポジトリを作成する。(方法2)

    vv init REPO_NAME WORK_DIR

ユーザ名を設定する。

    vv whoami --create USERNAME

参考：設定情報は以下のファイルに保管される。（ファイルはsqlite3データベース）

    $Env:LOCALAPPDATA\.sgcloset\settings.jsondb

参考：リポジトリは以下のフォルダ内に作成される。

    $Env:LOCALAPPDATA\.sgcloset\repo


### mavenリポジトリリスト

    # The MongoDB Java driver
    "org.mongodb" % "mongo-java-driver" % "2.11.3"


### GLOBALを使用したタグ生成

    gtags -vw | tee gtags.log
    htags --tabs 4 -sanofFTvxt 'TITLE' | tee htags.log


<!-- vim: set ts=4 sw=4 et:-->
