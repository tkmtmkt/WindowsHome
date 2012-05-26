############################################################
#
# 関数定義
#
############################################################

Function Add-Path
{
    Param([string]$item)

    if (-not $Env:PATH.ToUpper().Contains($item.ToUpper())) {
        $Env:PATH += ";$item"
    }
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

    $hashAlgorithm = [System.Security.Cryptography.MD5]::Create()

    @(ls $filePath) | ?{-not $_.PSIsContainer} | %{
        $inputStream = New-Object IO.StreamReader $_
        $hash = $hashAlgorithm.ComputeHash($inputStream.BaseStream);
        $inputStream.Close()

        $hashString = [System.BitConverter]::ToString($hash).ToLower().Replace("-","")

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

############################################################
#
# 環境設定（ツール）
#
############################################################
$TOOLDIR = "$Home\tool"

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
$OPTDIR = "$Home\opt"

Add-Path "$OPTDIR\bin"

# 構成管理
Add-Path "$OPTDIR\git"
Add-Path "$OPTDIR\git\cmd"
Add-Path "$OPTDIR\svn-win32\bin"
Add-Path "$OPTDIR\veracity"

# データベース
Add-Path "$OPTDIR\mongodb\bin"

# プログラミング
$tmp = "$Env:ProgramFiles\Java\jdk*"
If (Test-Path $tmp) {
    $Env:JAVA_HOME = @(ls $tmp | sort)[0].FullName
    Add-Path "$Env:JAVA_HOME\bin"
}

Add-Path "$OPTDIR\scala\bin"

Add-Path "$OPTDIR\jython"

$tmp = "$OPTDIR\clojure\clojure*.jar"
If (Test-Path $tmp) {
    $CLOJURE = @(ls $tmp | sort)[0].FullName
    $Env:CLOJURE_HOME = "$OPTDIR\clojure"
    Function clojure
    {
        $OFA = " "
        java.exe -cp $CLOJURE clojure.main "$args"
    }
}

Add-Path "$OPTDIR\ruby\bin"

# ビルド管理
Add-Path "$OPTDIR\apache-ant\bin"
Add-Path "$OPTDIR\apache-maven\bin"

Add-Path "$Home"

############################################################
#
# 環境設定（ユーザ作業用）
#
############################################################

# コンソール設定
$tmp = $Host.UI.RawUI.WindowSize
$tmp.Width  = 120
$tmp.Height = 35
$Host.UI.RawUI.WindowSize = $tmp
$Host.UI.RawUI.ForegroundColor="White"
$Host.UI.RawUI.BackgroundColor="Black"
cls

# 作業ディレクトリに移動する
$TODAYPATH = "$Home\work\$(Get-Date -f "yyyy\\MM\\yyyyMMdd")"
Function today {
    If (-not (Test-Path $TODAYPATH)) {
        New-Item $TODAYPATH -Force -ItemType Directory
    }
    If (-not (Test-Path today:)) {
        New-PSDrive today FileSystem $TODAYPATH -Scope Global
    }

    cd today:
}

# 作業メモを開く
Function memo
{
    $memo_file = "$TODAYPATH.mkd"
    If (-not (Test-Path $memo_file)) {
        If (-not (Test-Path (Split-Path $memo_file))) {
            New-Item (Split-Path $memo_file) -Force -ItemType Directory
        }
@" 
作業記録
========
開始：$(Get-Date -f "yyyy/MM/dd HH:mm")  
終了：

予定
----
* 
* 
* 
* 
* 

詳細
----

### 





メモ
----





参考
----
[1]: http://blog.2310.net/archives/6 "Markdownの文法"

<!-- vim: set ft=markdown ts=4 sw=4 et:-->
"@ | Out-File $memo_file -Encoding Default -Force
    }

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim $memo_file
    } else {
        notepad $memo_file
    }
}

# ショートカット用ドライブ設定
$drives = @{
    work = "$Home\work"
    apps = "$Home\apps"
}

Function go
{
    Param([string]$name)

    if ($drives[$name] -eq $null) {
        $drives
        return
    }

    if (-not (Test-Path "${name}:")) {
        New-PSDrive $name FileSystem $drives[$name] -Scope Global
    }
    cd "${name}:"
}

# vim: set ft=ps1 ts=4 sw=4 et:
