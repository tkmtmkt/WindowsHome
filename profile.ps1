############################################################
#
# 環境設定（ユーザ作業用）
#
############################################################
$TOOLDIR = "$Home\tool"
$APPSDIR = "$Home\apps"
$TODAYPATH = "$Home\work\$(Get-Date -f "yyyy\\MM\\yyyyMMdd")"

# コンソール設定
$tmp = $Host.UI.RawUI.WindowSize
$tmp.Width  = 120
$Host.UI.RawUI.WindowSize = $tmp
$Host.UI.RawUI.ForegroundColor="White"
$Host.UI.RawUI.BackgroundColor="Black"
cls

# フォルダへのショートカット用ドライブの設定
$drives = @{
    prof = "$(Split-Path $PROFILE)"
    tool = "$TOOLDIR"
    apps = "$APPSDIR"
    work = "$Home\work"
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
[Markdownの文法](http://blog.2310.net/archives/6)

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
        $out_file
    }
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
If (Test-Path "$TOOLDIR\vnc*") {
    Set-Alias vnc @(ls "$TOOLDIR\vnc*" | sort)[0].FullName
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
If (Test-Path $tmp) {
    $Env:JAVA_HOME = @(ls $tmp | sort)[0].FullName
    Add-Path "$Env:JAVA_HOME\bin"
}

Add-Path "$APPSDIR\scala\bin"

Add-Path "$APPSDIR\jython"

$tmp = "$APPSDIR\clojure\clojure*.jar"
If (Test-Path $tmp) {
    $CLOJURE = @(ls $tmp | sort)[0].FullName
    $Env:CLOJURE_HOME = "$APPSDIR\clojure"
    Function clojure
    {
        $OFA = " "
        java.exe -cp $CLOJURE clojure.main "$args"
    }
}

Add-Path "$APPSDIR\ruby\bin"

# ビルド管理
Add-Path "$APPSDIR\apache-ant\bin"
Add-Path "$APPSDIR\apache-maven\bin"

# その他
Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
