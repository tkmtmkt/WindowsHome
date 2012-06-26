SQLite Module
=============

準備
----

SQLite用のアセンブリファイルをダウンロードする。

[System.Data.SQLite Download Page](http://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki)

* sqlite-netFx40-static-binary-bundle-Win32-2010-1.0.81.0.zip
* sqlite-netFx40-static-binary-bundle-x64-2010-1.0.81.0.zip

以下のファイルをコピーする。

System.Data.SQLite.dll
System.Data.SQLite.Linq.dll

コピー先
$HOME/Documents/WindowsPowerShell/Modules/SQLite


使い方
------

    Import-Module SQLite

    Connect-SQLite [データベースファイル]

    Get-SQLiteData [テーブル]

    Get-SQLiteData -Query "SELECT * FROM テーブル"

    Disconnect-SQLite

<!-- vim: set ts=4 sw=4 et:-->
