############################################################
#
# 環境設定（ユーザ作業用）
#
############################################################
if ($Env:HOME -eq $null) {
    $Env:HOME = $Home
} else {
    if ($Env:HOME[-2] -ne ":") {
        $Env:HOME = $Env:HOME.TrimEnd("\")
    }
}
$TOOLDIR = "$Env:HOME\tool"
$APPSDIR = "$Env:HOME\apps"
$TODAYPATH = "$Env:HOME\work\$(Get-Date -f "yyyy\\MM\\yyyyMMdd")"

# コンソール設定
$Host.UI.RawUI | %{
    $tmp = $_.MaxPhysicalWindowSize
    $tmpHeight = $tmp.Height - 1
    $tmp.Width = 120
    $tmp.Height = 3000
    $_.BufferSize = $tmp
    $tmp.Height = $tmpHeight
    $_.WindowSize = $tmp

    $_.ForegroundColor = "White"
    $_.BackgroundColor = "Black"
    cls
}

# フォルダへのショートカット用ドライブの設定
$drives = @{
    tool = "$TOOLDIR"
    apps = "$APPSDIR"
    home = "$Env:HOME"
    work = "$Env:HOME\work"
    today = "$TODAYPATH"
}
$drives.Keys | %{
    New-Item Function: -name "${_}:" -value {
        <#
        .SYNOPSIS
        フォルダへのショートカット用ドライブに移動します。
        #>
        $drive = $MyInvocation.MyCommand.Name
        $name = $drive.substring(0, $drive.length - 1)
        $path = $drives[$name]

        If (-not (Test-Path $path)) {
            New-Item $path -Force -ItemType Directory | Out-Null
        }
        If (-not (Test-Path $drive)) {
            New-PSDrive $name FileSystem $path -Scope Global | Out-Null
        }
        cd $drive
    } | Out-Null
}
home:


############################################################
#
# 関数定義
#
############################################################
<#
.SYNOPSIS
作業記録メモを開きます。
#>
Function memo
{
    $memo_file = "$TODAYPATH.mkd"
    If (-not (Test-Path $memo_file)) {
        If (-not (Test-Path (Split-Path $memo_file))) {
            New-Item (Split-Path $memo_file) -Force -ItemType Directory | Out-Null
        }
@" 
作業記録
========
開始：$(Get-Date -f "yyyy/MM/dd HH:mm")  
終了：

予定
----
* 


実績
----

### 





メモ
----





参考
----
* [Markdownの文法](http://blog.2310.net/archives/6)

<!-- vim: set ft=markdown ts=4 sw=4 et:-->
"@ | Out-File $memo_file -Encoding Default -Force
    }

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim $memo_file
    } else {
        notepad $memo_file
    }
}

<#
.SYNOPSIS
ひとつ前の作業記録メモを開きます。
#>
function last
{
    $ErrorActionPreference = "Stop"

    $memo_file = @(ls (split-path $TODAYPATH) *.mkd)[-2].fullname
    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim -R $memo_file
    } else {
        notepad $memo_file
    }
}

<#
.SYNOPSIS
grepもどき。
#>
function grep
{
    param([string]$pattern, [string]$files)
    $ErrorActionPreference = "Stop"

    ls . $files -r | ?{-not $_.PSIsContainer} | %{
        select-string $pattern $_.fullname
    }
}

<#
.SYNOPSIS
クリップボート内の画像をファイルに出力します。
#>
Function cap
{
    powershell -sta -command {
    Add-Type -AssemblyName System.Windows.Forms
    $cb = [Windows.Forms.Clipboard]
    $img = $cb::GetImage()

    if ($img -ne $null) {
        $images = "$TODAYPATH\images"
        If(-not (Test-Path $images)) {
            New-Item $images -ItemType Directory -Force | Out-Null
        }
        [int]$fileno = ls $images | ?{$_.Name -match 'img(\d{3}).png'} |
            sort | select -last 1 | %{$Matches[1]}
        $out_file = "$images\img{0:000}.png" -f ($fileno + 1)

        $img.Save($out_file)
        (Resolve-Path $out_file).Path
    }
    }
}

<#
.SYNOPSIS
カレントフォルダをエクスプローラで表示します。
#>
Function exp
{
    explorer .
}

<#
.SYNOPSIS
指定したファイルのMD5ハッシュを取得します。
.PARAMETER filePath
ファイルパスを指定します。
#>
Function Get-Hash
{
    Param (
        [parameter(Mandatory=$true)][string]$filePath
    )

    $hashAlgorithm = [Security.Cryptography.MD5]::Create()

    @(ls $filePath) | ?{-not $_.PSIsContainer} | %{
        $inputStream = New-Object IO.StreamReader $_
        $hash = $hashAlgorithm.ComputeHash($inputStream.BaseStream);
        $inputStream.Close()

        $hashString = [BitConverter]::ToString($hash).ToLower().Replace("-","")

        "MD5($_) = $hashString"
    }
}

<#
.SYNOPSIS
現在のセッションにロードされたアセンブリを取得します。
#>
Function Get-Assemblies
{
    [Appdomain]::CurrentDomain.GetAssemblies()
}

<#
.SYNOPSIS
環境変数PATHに新しいパスを追加します。
.PARAMETER item
追加するパスを指定します。
#>
Function Add-Path
{
    Param([string]$item)

    if (-not $Env:PATH.ToUpper().Contains($item.ToUpper())) {
        $Env:PATH += ";$item"
    }
}

<#
.SYNOPSIS
sbtの初期プロジェクトを作成する。
#>
function sbt-init
{
    # 初期ディレクトリ作成
@" 
project
lib
src
src/main
src/main/scala
src/test
src/test/scala
"@ -split "`r*`n" | %{md $_}

    # ビルド設定ファイル作成
    $build_file = "build.sbt"
@" 

name := "My Project"

version := "0.1-SNAPSHOT"

organization := "home"

libraryDependencies += "junit" % "junit" % "4.8" % "test"
"@ | out-file $build_file -encoding UTF8

    # サンプルソースファイル作成
    $sample_file = "src/main/scala/Main.scala"
@" 
package home

object Main extends App
{
  println("Hello, world")
}
"@ | out-file $sample_file -encoding UTF8
}

############################################################
#
# 環境設定（ツール）
#
############################################################
Add-Path $TOOLDIR

# アーカイバ
Add-Path "$TOOLDIR\7-Zip"
Set-Alias zip "$TOOLDIR\7-Zip\7z.exe"

# エディタ
Add-Path "$TOOLDIR\vim"
Set-Alias vi "$TOOLDIR\vim\vim.exe"

# 差分ツール
Add-Path "$TOOLDIR\WinMerge"

# リモート接続
Add-Path "$TOOLDIR\teraterm"
Add-Path "$TOOLDIR\winscp"

$tmp = "$TOOLDIR\vnc*"
If (Test-Path $tmp -ErrorAction SilentlyContinue) {
    Set-Alias vnc @(ls $tmp | sort -desc)[0].FullName
}

# システム管理
Add-Path "$TOOLDIR\SysinternalsSuite"
Add-Path "$TOOLDIR\Log Parser 2.2"
Add-Path "$TOOLDIR\SUPPORT"

# 構成管理
Set-Alias fos "$TOOLDIR\fossil.exe"

# データベース
Set-Alias sql "$TOOLDIR\sqlite3.exe"


############################################################
#
# 環境設定（オプションツール）
#
############################################################
Add-Path "$APPSDIR\bin"

# 構成管理
Add-Path "$APPSDIR\git"
Add-Path "$APPSDIR\git\cmd"
Add-Path "$APPSDIR\svn-win32\bin"
Add-Path "$APPSDIR\veracity"

# データベース
Add-Path "$APPSDIR\mongodb\bin"

# プログラミング
$tmp = "$Env:ProgramFiles\Java\jdk*"
If (Test-Path $tmp -ErrorAction SilentlyContinue) {
    $Env:JAVA_HOME = @(ls $tmp | sort -desc)[0].FullName
    Add-Path "$Env:JAVA_HOME\bin"
#    $Env:JAVA_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"
}

Add-Path "$APPSDIR\scala\bin"

Add-Path "$APPSDIR\jython"

$tmp = "$APPSDIR\clojure\clojure*.jar"
If (Test-Path $tmp -ErrorAction SilentlyContinue) {
    $CLOJURE = @(ls $tmp | sort -desc)[0].FullName
    Function clojure
    {
        $OFA = " "
        java -cp $CLOJURE clojure.main "$args"
    }
}

Add-Path "$APPSDIR\ruby\bin"

# ビルド管理
Add-Path "$APPSDIR\apache-ant\bin"
Add-Path "$APPSDIR\apache-maven\bin"

# その他
Add-Path "$APPSDIR\astah_community"
Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
