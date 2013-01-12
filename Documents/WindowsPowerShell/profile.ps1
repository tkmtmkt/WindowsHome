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
$BASEDIR = "$Env:HOME\work"
function TODAYPATH {"$BASEDIR\$(date -f 'yyyy\\MM\\yyyyMMdd')"}
$WORKDIR = (TODAYPATH)

# コンソール設定
$Host.UI.RawUI | %{
    $height = $_.MaxPhysicalWindowSize.Height - 2
    $_.WindowSize = new-object Management.Automation.Host.Size(120, $height)
    $_.BufferSize = new-object Management.Automation.Host.Size(120, 3000)
    $_.ForegroundColor = "White"
    $_.BackgroundColor = "Black"
    cls
}

# プロンプト設定
function prompt {
    write-host "$($Env:USERDOMAIN)\$($Env:USERNAME) " -NoNewline -ForegroundColor "Green"
    write-host "$PWD" -ForegroundColor "DarkCyan"
    $(if (test-path Variable:/PSDebugContext) { '[DBG]: ' } else { '' }) +
    "PS $(date -f 'yyyy/MM/dd HH:mm:ss')$('>' * ($NestedPromptLevel + 1)) "
}

# ショートカット：SSH接続
function ssh-sakura {ttermpro $Env:USERNAME@www.sakura.ne.jp /P=22 /L=$(log "sakura-")}

# ショートカット：ドライブ指定
$drives = @{
    tool = "$TOOLDIR"
    apps = "$APPSDIR"
    home = "$Env:HOME"
    work = "$WORKDIR"
    today = "$(TODAYPATH)"
}
$drives.Keys | %{
    New-Item Function: -name "${_}:" -value {
        <#
        .SYNOPSIS
        フォルダへのショートカット用ドライブに移動します。
        #>
        $drive = $MyInvocation.MyCommand.Name
        $name = $drive.trim(":")
        $path = $drives[$name]

        If (-not (Test-Path $path)) {
            New-Item $path -ItemType Directory -Force | Out-Null
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
ログファイル名を生成します。
.PARAMETER id
ログファイル名の先頭に付ける識別を指定します。
#>
function log {
    param (
        [string]$id = $null
    )
    if (-not (test-path (TODAYPATH))) {
        new-item (TODAYPATH) -type dir -force | out-null
    }
    "$(TODAYPATH)\$(if ($id -ne $null) {"$id"})$(date -f 'yyyyMMddHHmmss').log"
}

<#
.SYNOPSIS
作業記録メモを開きます。
#>
Function memo {
    $file = "$WORKDIR.mkd"
    If (-not (Test-Path $file)) {
        If (-not (Test-Path (Split-Path $file))) {
            new-item (Split-Path $file) -type dir -force | Out-Null
        }
@" 
作業記録
========
開始：$(date -f 'yyyy/MM/dd HH:mm')  
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
"@ | Out-File $file -Encoding Default -Force
    }

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim $file
    } else {
        notepad $file
    }
}

<#
.SYNOPSIS
ひとつ前の作業記録メモを開きます。
#>
function last {
    $ErrorActionPreference = "Stop"

    $file = @(ls $BASEDIR *.mkd -r)[-2].fullname
    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim -R $file
    } else {
        notepad $file
    }
}

<#
.SYNOPSIS
README.mdファイルを開きます。
#>
function readme {
    $file = "README.md"
    If (-not (Test-Path $file)) {
@" 
タイトル
========

大項目
------

### 中項目

<!-- vim: set ts=4 sw=4 et:-->
"@ | Out-File $file -Encoding UTF8 -Force
    }

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim $file
    } else {
        notepad $file
    }
}

<#
.SYNOPSIS
grepもどき。
#>
function grep {
    param(
        [string]$pattern,
        [string]$files
    )
    $ErrorActionPreference = "Stop"

    ls . $files -r | ?{-not $_.PSIsContainer} | %{
        select-string $pattern $_.fullname
    }
}

<#
.SYNOPSIS
クリップボート内の画像をファイルに出力します。
#>
Function cap {
    powershell -sta -command {
    Add-Type -AssemblyName System.Windows.Forms
    $cb = [Windows.Forms.Clipboard]
    $img = $cb::GetImage()

    if ($img -ne $null) {
        $images = "$WORKDIR\images"
        If(-not (Test-Path $images)) {
            New-Item $images -type dir -force | Out-Null
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
指定したファイルのハッシュを取得します。
.PARAMETER hashAlgorithm
ハッシュアルゴリズムを指定します。
.PARAMETER filePath
ファイルパスを指定します。
#>
Function Get-Hash {
    Param (
        [parameter(Mandatory=$true)][Security.Cryptography.HashAlgorithm]$hashAlgorithm,
        [parameter(Mandatory=$true)][string]$fileName
    )

    # ハッシュ作成
    $inputStream = New-Object IO.StreamReader $fileName
    $hash = $hashAlgorithm.ComputeHash($inputStream.BaseStream);
    $inputStream.Close()

    # 文字列に変換
    [BitConverter]::ToString($hash).ToLower().Replace("-","")
}

<#
.SYNOPSIS
指定したファイルのMD5ハッシュを取得します。
.PARAMETER filePath
ファイルパスを指定します。
#>
function md5sum {
    Param (
        [parameter(Mandatory=$true)][string]$filePath
    )

    $hashAlgorithm = [Security.Cryptography.MD5]::Create()
    @(ls $filePath) | ?{-not $_.PSIsContainer} | %{
        "$(Get-Hash $hashAlgorithm $_.FullName) $($_.Name)"
    }
}

<#
.SYNOPSIS
指定したファイルのSHA1ハッシュを取得します。
.PARAMETER filePath
ファイルパスを指定します。
#>
function sha1sum {
    Param (
        [parameter(Mandatory=$true)][string]$filePath
    )

    $hashAlgorithm = [Security.Cryptography.SHA1]::Create()
    @(ls $filePath) | ?{-not $_.PSIsContainer} | %{
        "$(Get-Hash $hashAlgorithm $_.FullName) $($_.Name)"
    }
}

<#
.SYNOPSIS
現在のセッションにロードされたアセンブリを取得します。
#>
Function Get-Assemblies {
    [Appdomain]::CurrentDomain.GetAssemblies()
}

<#
.SYNOPSIS
指定したパスから最新の項目を取得します。
.PARAMETER Path
ワイルドカードを含むパスを指定します。
#>
function Get-LatestPath {
    param(
        [string]$Path
    )

    @(ls "$Path" -ea SilentlyContinue | sort -desc)[0].fullname
}

<#
.SYNOPSIS
環境変数PATHに新しいパスを追加します。
.PARAMETER Item
追加するパスを指定します。
#>
Function Add-Path {
    Param(
        [string]$Item
    )

    if ($Item -eq $null -or
        $Env:PATH.ToUpper().Contains($Item.ToUpper())) {return}

    $Env:PATH += ";$Item"
}

<#
.SYNOPSIS
sbtの初期プロジェクトを作成する。
#>
function sbt-init {
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

<#
.SYNOPSIS
PowerShellを実行するCRLバージョンを設定する
#>
function Set-CLRVersion {
    param(
        [parameter(Mandatory=$true)]
        [string]
        [ValidatePattern("[24]")]
        $version
    )

    $configFile = "$PSHome/powershell.exe.config"
    $template = @" 
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <startup useLegacyV2RuntimeActivationPolicy="true" >
    <supportedRuntime version="{0}" />
  </startup>
  <runtime>
    <loadFromRemoteSources enabled="true" />
  </runtime>
</configuration>
"@

    if ($version -eq "2") {
        if (test-path $configFile) {
            rm $configFile
        }
    } elseif ($version -eq "4" ) {
        $template -f "v4.0" | out-file $configFile -encoding UTF8
    }
}


############################################################
#
# 環境設定（ツール）
#
############################################################
Add-Path $TOOLDIR

# アーカイバ
Add-Path "$TOOLDIR\7-Zip"
Set-Alias zip  "$TOOLDIR\7-Zip\7z.exe"
Set-Alias zipw "$TOOLDIR\7-Zip\7zFM.exe"

# エディタ
$VIM_HOME = Get-LatestPath "$TOOLDIR\vim*"
Add-Path "$VIM_HOME"
Set-Alias vi "$VIM_HOME\vim.exe"
$Env:EDITOR = "gvim"

# 差分ツール
$WINMERGE_HOME = Get-LatestPath "$TOOLDIR\WinMerge*"
Add-Path "$WINMERGE_HOME"

# リモート接続
$TERATERM_HOME = Get-LatestPath "$TOOLDIR\teraterm*"
Add-Path "$TERATERM_HOME"

$WINSCP_HOME = Get-LatestPath "$TOOLDIR\winscp*"
Add-Path "$WINSCP_HOME"

$VNC = Get-LatestPath "$TOOLDIR\vnc*"
if ($VNC -ne $null) {Set-Alias vnc $VNC}

# システム管理
Add-Path "$TOOLDIR\SysinternalsSuite"

Add-Path "$TOOLDIR\rktools"

Add-Path "$TOOLDIR\SUPPORT"

Add-Path "$TOOLDIR\Log Parser 2.2"

$LOGEXPERT_HOME = Get-LatestPath "$TOOLDIR\LogExpert*"
Add-Path "$LOGEXPERT_HOME"

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
$GIT_HOME = Get-LatestPath "$APPSDIR\*git*"
Add-Path "$GIT_HOME"
Add-Path "$GIT_HOME\cmd"

$SVN_HOME = Get-LatestPath "$APPSDIR\svn*"
Add-Path "$SVN_HOME\bin"

$VERACITY_HOME = Get-LatestPath "$APPSDIR\vv_*"
Add-Path "$VERACITY_HOME"

# データベース
$MONGODB_HOME = Get-LatestPath "$APPSDIR\mongodb*"
Add-Path "$MONGODB_HOME\bin"

# プログラミング
$Env:JAVA_HOME = Get-LatestPath "$Env:ProgramFiles\Java\jdk1.6*"
Add-Path "$Env:JAVA_HOME\bin"
$Env:CLASS_PATH = "$Env:JAVA_HOME\lib\tools.jar"
#$Env:JAVA_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"

$SCALA_HOME = Get-LatestPath "$APPSDIR\scala*"
Add-Path "$SCALA_HOME\bin"

Function sbt {
    $sbt = Get-LatestPath "$APPSDIR\bin\sbt-launch*.jar"
    If ($sbt -ne $null) {
        $argList  = @("$Env:JAVA_OPTS -Xms512M -Xmx1792M -Xss1M")
        $argList += @("-XX:MaxPermSize=200M -XX:ReservedCodeCacheSize=60M")
        $argList += @("-XX:+CMSClassUnloadingEnabled -XX:-UseGCOverheadLimit")
        $argList += @("-jar $sbt")
        $argList += $args

        start java $argList -NoNewWindow -Wait
    }
}

Function clojure {
    $clojure = Get-LatestPath "$APPSDIR\clojure\clojure*.jar"
    If ($clojure -ne $null) {
        $argList  = @("-cp $clojure clojure.main")
        $argList += $args

        start java $argList -NoNewWindow -Wait
    }
}

$PYTHON_HOME = Get-LatestPath "$APPSDIR\python*"
Add-Path "$PYTHON_HOME"
Add-Path "$PYTHON_HOME\Scripts"

$JYTHON_HOME = Get-LatestPath "$APPSDIR\jython*"
Add-Path "$JYTHON_HOME"

$RUBY_HOME = Get-LatestPath "$APPSDIR\ruby*"
Add-Path "$RUBY_HOME\bin"

# ビルド管理
$ANT_HOME = Get-LatestPath "$APPSDIR\apache-ant*"
Add-Path "$ANT_HOME\bin"

$MVN_HOME = Get-LatestPath "$APPSDIR\apache-maven*"
Add-Path "$MVN_HOME\bin"

# その他
$PANDOC_HOME = Get-LatestPath "$APPSDIR\pandoc*"
Add-Path "$PANDOC_HOME\bin"

Add-Path "$APPSDIR\astah_community"

Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
