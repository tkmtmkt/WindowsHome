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
$TOOLDIR = "$Env:PUBLIC\tool"
$APPSDIR = "$Env:PUBLIC\apps"
$PROJDIR = "$Env:PUBLIC\projects"
$REPODIR = "$Env:PUBLIC\repos"
function Get-TodayPath {"$Env:HOME\work\$(Get-Date (Get-Date).AddHours(-5) -f 'yyyy\\MM\\dd')"}
$WORKDIR = $(Get-TodayPath)

# コンソール設定
$Host.UI.RawUI | %{
    $height = $_.MaxPhysicalWindowSize.Height - 2
    $width  = 120
    $buffer = 3000
    if ($_.BufferSize.Width -lt $width) {
        $_.BufferSize = new-object Management.Automation.Host.Size($width, $buffer)
        $_.WindowSize = new-object Management.Automation.Host.Size($width, $height)
    } else {
        $_.WindowSize = new-object Management.Automation.Host.Size($width, $height)
        $_.BufferSize = new-object Management.Automation.Host.Size($width, $buffer)
    }
    $_.ForegroundColor = "White"
    $_.BackgroundColor = "Black"
    cls
}

# プロンプト設定
function prompt {
    write-host "$Env:USERDOMAIN\$Env:USERNAME " -NoNewline -ForegroundColor "Green"
    write-host "$PWD" -NoNewline -ForegroundColor "DarkCyan"
    if (!$PWD.ProviderPath.StartsWith($Home)) { Write-VcsStatus }
    write-host ""
    $(if (test-path Variable:/PSDebugContext) { '[DBG]: ' } else { '' }) +
    "PS $(Get-Date -u '%T')$('>' * ($NestedPromptLevel + 1)) "
}

# ショートカット：SSH接続
cat C:\Windows\system32\drivers\etc\hosts |
?{$_ -match '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'} |
%{@($_ -split "#",2)[0].trim()} | ?{$_.length -gt 0} | %{
    $name = "ssh-$(@($_ -split "\s+")[1])"
    new-item function: -name $name -value {
        param([string]$user = $Env:USERNAME)
        $hostname = ($MyInvocation.MyCommand.Name -split "-",2)[1]
        ttermpro ssh://$user@$hostname /auth=publickey /keyfile="$Home\.ssh\id_rsa" /ask4passwd /L="$(log "${hostname}-")"
    } | out-null
}
function ssh-sakura {ttermpro ssh://$Env:USERNAME@www.sakura.ne.jp /auth=publickey /keyfile="$Home\.ssh\id_rsa" /L=$(log "sakura-")}

# ショートカット：仮想マシン起動
@(ls $Home\Documents *.vmx -r -ea:SilentlyContinue) | ?{$_.name -match "vmx$"} | %{
    new-item function: -name "vmx-$($_.basename)" -value {
        $vmx_file = $(ls $Home\Documents "$(($MyInvocation.MyCommand.Name -split '-',2)[1]).vmx" -r).fullname
        start "$vmx_file"
    } | out-null
}

# ショートカット：RDP接続
@(ls $Home\Documents *.rdp -ea:SilentlyContinue) | %{
    new-item function: -name "rdp-$($_.basename)" -value {
        $rdp_file = "$Home\Documents\$(($MyInvocation.MyCommand.Name -split '-',2)[1]).rdp"
        mstsc "$rdp_file"
    } | out-null
}

# ショートカット：ドライブ指定
$drives = @{
    PUBLIC = "$Env:PUBLIC"
    HOME = "$Env:HOME"
    TOOL = "$TOOLDIR"
    APPS = "$APPSDIR"
    PROJ = "$PROJDIR"
    GIT  = "$REPODIR\git"
    SVN  = "$REPODIR\svn"
    HG   = "$REPODIR\hg"
    VZR  = "$REPODIR\vzr"
    VV   = "$REPODIR\veracity"
    FOS  = "$REPODIR\fossil"
    WORK = "$WORKDIR"
    WKSP = "$Env:PUBLIC\workspace"
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

        If (!(Test-Path $path)) {
            New-Item $path -ItemType Directory -Force | Out-Null
        }
        If (!(Test-Path $drive)) {
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
新しいコンソールを開きます。
#>
function console {
    param([switch]$admin)

    $script = @"
cd '$($PWD.ProviderPath)'
`$Host.UI.RawUI.WindowTitle = '$($Host.UI.RawUI.WindowTitle)'
"@
    if ($admin) {
        start powershell "-NoExit","-Command",$script -Verb RunAs
    } else {
        start powershell "-NoExit","-Command",$script
    }
}

<#
.SYNOPSIS
管理者権限の有無を判定します。
#>
function IsAdministrator {
    [Security.Principal.WindowsPrincipal]$id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
シンボリックリンクを作成します。
#>
function ln {
    param(
        [parameter(Mandatory=$true)]
        [ValidateScript({test-path $_})]
        [string]$target,
        [string]$link
    )

    $target_path = (resolve-path $target).ProviderPath

    if ($link -eq $null -or $link -eq "") {
        $link_name = split-path $target_path -leaf
    } else {
        $link_name = split-path $link -leaf
    }

    $option = "/D" * (test-path $target_path -type container)

    $script = @"
cd '$($PWD.ProviderPath)'
cmd /c mklink $option '$link_name' '$target_path'
write-host "Enterを押してください..."
read-host | out-null
"@

    if (IsAdministrator) {
        Invoke-Expression $script
    } else {
        start powershell @("-NoProfile -Command",$script) -Verb RunAs
    }
}

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
    $todaypath = Get-TodayPath
    if (!(test-path $todaypath)) {
        new-item $todaypath -type dir -force | out-null
    }
    "$todaypath\$(if ($id -ne $null) {"$id"})$(Get-Date -f 'yyyyMMddHHmmss').log"
}

<#
.SYNOPSIS
コンソールの入出力を記録します。
#>
function start-log {start-transcript $(log "posh-$PID-")}

<#
.SYNOPSIS
作業記録メモを開きます。
#>
Function memo {
    $file = "$WORKDIR\$(Get-Date -f 'yyyyMMdd').mkd"
    If (!(Test-Path $file)) {
        If (!(Test-Path (Split-Path $file))) {
            new-item (Split-Path $file) -type dir -force | Out-Null
        }
@" 
作業記録
========
開始：$(Get-Date -f 'yyyy/MM/dd HH:mm')  
終了：

今週の予定
----------
* 


今日の実績
----------

### 










メモ
----





参考
----
* [Markdownの文法](http://blog.2310.net/archives/6)

<!-- vim: set ft=markdown ts=4 sw=4 et:-->
"@ | Out-File $file -Encoding Default -Force
    }

    If ((Get-Command gvim -ea:SilentlyContinue) -ne $null) {
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
    try {
        $dir = $(split-path $(split-path $WORKDIR))
        $file = @(ls $dir *.mkd -r | select -last 2)[-2].fullname
        If ((Get-Command gvim -ea:SilentlyContinue) -ne $null) {
            gvim -R $file
        } else {
            notepad $file
        }
    } catch {
        $_
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

    If ((Get-Command gvim -ea:SilentlyContinue) -ne $null) {
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
.PARAMETER HashAlgorithm
ハッシュアルゴリズムを指定します。
.PARAMETER FileName
ファイル名を指定します。
#>
Function Get-Hash {
    Param (
        [parameter(Mandatory=$true)][Security.Cryptography.HashAlgorithm]$HashAlgorithm,
        [parameter(Mandatory=$true)][string]$FileName
    )

    # ハッシュ作成
    $inputStream = New-Object IO.StreamReader $FileName
    $hash = $HashAlgorithm.ComputeHash($inputStream.BaseStream);
    $inputStream.Close()

    # 文字列に変換
    [BitConverter]::ToString($hash).ToLower().Replace("-","")
}

<#
.SYNOPSIS
指定したファイルのMD5ハッシュを取得します。
.PARAMETER FilePath
ファイルパスを指定します。
#>
function md5sum {
    Param (
        [parameter(Mandatory=$true)][string]$FilePath
    )

    $hashAlgorithm = [Security.Cryptography.MD5]::Create()
    @(ls $FilePath) | ?{-not $_.PSIsContainer} |
        select @{Label="Checksum";Expression={$(Get-Hash $hashAlgorithm $_.FullName)}},Name
}

<#
.SYNOPSIS
指定したファイルのSHA1ハッシュを取得します。
.PARAMETER FilePath
ファイルパスを指定します。
#>
function sha1sum {
    Param (
        [parameter(Mandatory=$true)][string]$FilePath
    )

    $hashAlgorithm = [Security.Cryptography.SHA1]::Create()
    @(ls $FilePath) | ?{-not $_.PSIsContainer} |
        select @{Label="Checksum";Expression={$(Get-Hash $hashAlgorithm $_.FullName)}},Name
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

    if (test-path $Path) {
        @(ls $Path -ea:SilentlyContinue | sort -desc)[0].fullname
    }
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

<#
.SYNOPSIS
コンピュータの起動／停止履歴を取得する。
#>
function Get-RestartLog {
    Get-EventLog System |
    ?{$_.Source -match '(USER32|EventLog)' -and 1074,1076,6005,6006,6008 -contains $_.EventId} | %{
        $record = new-object PSObject -property @{
            Time = $_.TimeGenerated
            EventId = $_.EventId
        }
        if ($Matches[1] -eq 'USER32') {
            $_.Message -split "`r`n" | ?{$_.Length -gt 0} | %{
                $line = $_ -split ":(?!\\)",2
                if ($line[0] -match "次の理由") {$line[0] = "理由"}
                add-member NoteProperty $line[0].trim() -InputObject $record $line[1].trim()
            }
        } else {
            add-member NoteProperty 'コメント' -InputObject $record $_.Message
        }
        $record
    } | select Time,EventId,シャットダウンの種類,理由,理由コード,コメント
}

"eclipse","pleiades" | %{
    New-Item Function: -name $_ -force -value {
        <#
        .SYNOPSIS
        eclipseを起動します。
        #>
        param(
            $findword
        )
        $name = $MyInvocation.MyCommand.Name
        ls "$APPSDIR\$name*" | ?{$_.name -match $findword} | select -last 1 | %{
            $dir = "$($_.fullname)\eclipse"
            "Starting $name in $dir" | out-host
            start "$dir\eclipse.exe" -work $dir
        }
    } | out-null
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

# バイナリエディタ
Add-Path "$TOOLDIR\FavBinEdit"
Set-Alias binedit "$TOOLDIR\FavBinEdit\FavBinEdit.exe"
Set-Alias bingrep "$TOOLDIR\FavBinEdit\FavBinGrep.exe"

# 階層化情報管理ツール
$ZEETA_HOME = "$TOOLDIR\Zeeta"
function zeeta {
    pushd $ZEETA_HOME\startup
    javaw -jar $ZEETA_HOME\lib\selj.jar
    popd
}

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
Add-Path "$GIT_HOME\bin"
Import-Module posh-git
Enable-GitColors

$SVN_HOME = Get-LatestPath "$APPSDIR\svn*"
Add-Path "$SVN_HOME\bin"

$VERACITY_HOME = Get-LatestPath "$APPSDIR\veracity_*"
Add-Path "$VERACITY_HOME"

# データベース
$MONGODB_HOME = Get-LatestPath "$APPSDIR\mongodb*"
Add-Path "$MONGODB_HOME\bin"

# プログラミング
$Env:JAVA_HOME = Get-LatestPath "$Env:ProgramFiles\Java\jdk*"
#$Env:JAVA_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"

$PLEIADES_HOME = Get-LatestPath "$APPSDIR\pleiades*"
if ($Env:JAVA_HOME -eq $null -and $PLEIADES_HOME -ne $null) {
    $Env:JAVA_HOME = "$PLEIADES_HOME\java\7"
}

if ($Env:JAVA_HOME -ne $null) {
    Add-Path "$Env:JAVA_HOME\bin"
    $Env:CLASS_PATH = "$Env:JAVA_HOME\lib\tools.jar"
}

$SCALA_HOME = Get-LatestPath "$APPSDIR\scala*"
Add-Path "$SCALA_HOME\bin"

Function clojure {
    $clojure = Get-LatestPath "$APPSDIR\clojure*\clojure*.jar"
    If ($clojure -ne $null) {
        $argList  = @("-cp $clojure clojure.main")
        $argList += $args

        start java $argList -NoNewWindow -Wait
    }
}

$GROOVY_HOME = Get-LatestPath "$APPSDIR\groovy*"
Add-Path "$GROOVY_HOME\bin"

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
#$Env:ANT_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"

$MVN_HOME = Get-LatestPath "$APPSDIR\apache-maven*"
Add-Path "$MVN_HOME\bin"

$GRADLE_HOME = Get-LatestPath "$APPSDIR\gradle*"
Add-Path "$GRADLE_HOME\bin"

Add-Path "$Env:HOME\.sbt"

Add-Path "$Env:HOME\.lein"

# その他
$PANDOC_HOME = Get-LatestPath "$APPSDIR\pandoc*"
Add-Path "$PANDOC_HOME\bin"

$PHANTOMJS_HOME = Get-LatestPath "$APPSDIR\phantomjs-*"
Add-Path "$PHANTOMJS_HOME\bin"

$GLOBAL_HOME = Get-LatestPath "$APPSDIR\global*"
Add-Path "$GLOBAL_HOME\bin"

Add-Path "$APPSDIR\astah_community"

Add-Path "$APPSDIR\playframework"

$BEITEL_HOME = Get-LatestPath "$APPSDIR\beitel-*"
Add-Path "$BEITEL_HOME"

function memo-monthly {
    $dir  = "$Env:HOME\work\$(Get-Date -f 'yyyy\\MM')"
    $file = "$(Get-Date -f 'yyyy-MM').zte"

    if (Test-Path "$dir\$file") {
        start beitel "$dir\$file" -Work "$dir"
    } else {
        start beitel -Work "$dir"
    }
}

function zeeta {
    start run.bat -Work "$APPSDIR\Zeeta\startup"
}

# vim: set ft=ps1 ts=4 sw=4 et:
