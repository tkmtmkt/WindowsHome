############################################################
#
# ���ݒ�i���[�U��Ɨp�j
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

# �R���\�[���ݒ�
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

# �v�����v�g�ݒ�
function prompt {
    write-host "$Env:USERDOMAIN\$Env:USERNAME " -NoNewline -ForegroundColor "Green"
    write-host "$PWD" -NoNewline -ForegroundColor "DarkCyan"
    if (!$PWD.ProviderPath.StartsWith($Home)) { Write-VcsStatus }
    write-host ""
    $(if (test-path Variable:/PSDebugContext) { '[DBG]: ' } else { '' }) +
    "PS $(Get-Date -u '%T')$('>' * ($NestedPromptLevel + 1)) "
}

# �V���[�g�J�b�g�FSSH�ڑ�
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

# �V���[�g�J�b�g�F���z�}�V���N��
@(ls $Home\Documents *.vmx -r -ea:SilentlyContinue) | ?{$_.name -match "vmx$"} | %{
    new-item function: -name "vmx-$($_.basename)" -value {
        $vmx_file = $(ls $Home\Documents "$(($MyInvocation.MyCommand.Name -split '-',2)[1]).vmx" -r).fullname
        start "$vmx_file"
    } | out-null
}

# �V���[�g�J�b�g�FRDP�ڑ�
@(ls $Home\Documents *.rdp -ea:SilentlyContinue) | %{
    new-item function: -name "rdp-$($_.basename)" -value {
        $rdp_file = "$Home\Documents\$(($MyInvocation.MyCommand.Name -split '-',2)[1]).rdp"
        mstsc "$rdp_file"
    } | out-null
}

# �V���[�g�J�b�g�F�h���C�u�w��
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
        �t�H���_�ւ̃V���[�g�J�b�g�p�h���C�u�Ɉړ����܂��B
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
# �֐���`
#
############################################################
<#
.SYNOPSIS
�V�����R���\�[�����J���܂��B
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
�Ǘ��Ҍ����̗L���𔻒肵�܂��B
#>
function IsAdministrator {
    [Security.Principal.WindowsPrincipal]$id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
�V���{���b�N�����N���쐬���܂��B
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
write-host "Enter�������Ă�������..."
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
���O�t�@�C�����𐶐����܂��B
.PARAMETER id
���O�t�@�C�����̐擪�ɕt���鎯�ʂ��w�肵�܂��B
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
�R���\�[���̓��o�͂��L�^���܂��B
#>
function start-log {start-transcript $(log "posh-$PID-")}

<#
.SYNOPSIS
��ƋL�^�������J���܂��B
#>
Function memo {
    $file = "$WORKDIR\$(Get-Date -f 'yyyyMMdd').mkd"
    If (!(Test-Path $file)) {
        If (!(Test-Path (Split-Path $file))) {
            new-item (Split-Path $file) -type dir -force | Out-Null
        }
@" 
��ƋL�^
========
�J�n�F$(Get-Date -f 'yyyy/MM/dd HH:mm')  
�I���F

���T�̗\��
----------
* 


�����̎���
----------

### 










����
----





�Q�l
----
* [Markdown�̕��@](http://blog.2310.net/archives/6)

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
�ЂƂO�̍�ƋL�^�������J���܂��B
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
README.md�t�@�C�����J���܂��B
#>
function readme {
    $file = "README.md"
    If (-not (Test-Path $file)) {
@" 
�^�C�g��
========

�區��
------

### ������

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
grep���ǂ��B
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
�N���b�v�{�[�g���̉摜���t�@�C���ɏo�͂��܂��B
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
�w�肵���t�@�C���̃n�b�V�����擾���܂��B
.PARAMETER HashAlgorithm
�n�b�V���A���S���Y�����w�肵�܂��B
.PARAMETER FileName
�t�@�C�������w�肵�܂��B
#>
Function Get-Hash {
    Param (
        [parameter(Mandatory=$true)][Security.Cryptography.HashAlgorithm]$HashAlgorithm,
        [parameter(Mandatory=$true)][string]$FileName
    )

    # �n�b�V���쐬
    $inputStream = New-Object IO.StreamReader $FileName
    $hash = $HashAlgorithm.ComputeHash($inputStream.BaseStream);
    $inputStream.Close()

    # ������ɕϊ�
    [BitConverter]::ToString($hash).ToLower().Replace("-","")
}

<#
.SYNOPSIS
�w�肵���t�@�C����MD5�n�b�V�����擾���܂��B
.PARAMETER FilePath
�t�@�C���p�X���w�肵�܂��B
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
�w�肵���t�@�C����SHA1�n�b�V�����擾���܂��B
.PARAMETER FilePath
�t�@�C���p�X���w�肵�܂��B
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
���݂̃Z�b�V�����Ƀ��[�h���ꂽ�A�Z���u�����擾���܂��B
#>
Function Get-Assemblies {
    [Appdomain]::CurrentDomain.GetAssemblies()
}

<#
.SYNOPSIS
�w�肵���p�X����ŐV�̍��ڂ��擾���܂��B
.PARAMETER Path
���C���h�J�[�h���܂ރp�X���w�肵�܂��B
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
���ϐ�PATH�ɐV�����p�X��ǉ����܂��B
.PARAMETER Item
�ǉ�����p�X���w�肵�܂��B
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
PowerShell�����s����CRL�o�[�W������ݒ肷��
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
�R���s���[�^�̋N���^��~�������擾����B
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
                if ($line[0] -match "���̗��R") {$line[0] = "���R"}
                add-member NoteProperty $line[0].trim() -InputObject $record $line[1].trim()
            }
        } else {
            add-member NoteProperty '�R�����g' -InputObject $record $_.Message
        }
        $record
    } | select Time,EventId,�V���b�g�_�E���̎��,���R,���R�R�[�h,�R�����g
}

"eclipse","pleiades" | %{
    New-Item Function: -name $_ -force -value {
        <#
        .SYNOPSIS
        eclipse���N�����܂��B
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
# ���ݒ�i�c�[���j
#
############################################################
Add-Path $TOOLDIR

# �A�[�J�C�o
Add-Path "$TOOLDIR\7-Zip"
Set-Alias zip  "$TOOLDIR\7-Zip\7z.exe"
Set-Alias zipw "$TOOLDIR\7-Zip\7zFM.exe"

# �G�f�B�^
$VIM_HOME = Get-LatestPath "$TOOLDIR\vim*"
Add-Path "$VIM_HOME"
Set-Alias vi "$VIM_HOME\vim.exe"
$Env:EDITOR = "gvim"

# �o�C�i���G�f�B�^
Add-Path "$TOOLDIR\FavBinEdit"
Set-Alias binedit "$TOOLDIR\FavBinEdit\FavBinEdit.exe"
Set-Alias bingrep "$TOOLDIR\FavBinEdit\FavBinGrep.exe"

# �K�w�����Ǘ��c�[��
$ZEETA_HOME = "$TOOLDIR\Zeeta"
function zeeta {
    pushd $ZEETA_HOME\startup
    javaw -jar $ZEETA_HOME\lib\selj.jar
    popd
}

# �����c�[��
$WINMERGE_HOME = Get-LatestPath "$TOOLDIR\WinMerge*"
Add-Path "$WINMERGE_HOME"

# �����[�g�ڑ�
$TERATERM_HOME = Get-LatestPath "$TOOLDIR\teraterm*"
Add-Path "$TERATERM_HOME"

$WINSCP_HOME = Get-LatestPath "$TOOLDIR\winscp*"
Add-Path "$WINSCP_HOME"

$VNC = Get-LatestPath "$TOOLDIR\vnc*"
if ($VNC -ne $null) {Set-Alias vnc $VNC}

# �V�X�e���Ǘ�
Add-Path "$TOOLDIR\SysinternalsSuite"

Add-Path "$TOOLDIR\rktools"

Add-Path "$TOOLDIR\SUPPORT"

Add-Path "$TOOLDIR\Log Parser 2.2"

$LOGEXPERT_HOME = Get-LatestPath "$TOOLDIR\LogExpert*"
Add-Path "$LOGEXPERT_HOME"

# �\���Ǘ�
Set-Alias fos "$TOOLDIR\fossil.exe"

# �f�[�^�x�[�X
Set-Alias sql "$TOOLDIR\sqlite3.exe"


############################################################
#
# ���ݒ�i�I�v�V�����c�[���j
#
############################################################
Add-Path "$APPSDIR\bin"

# �\���Ǘ�
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

# �f�[�^�x�[�X
$MONGODB_HOME = Get-LatestPath "$APPSDIR\mongodb*"
Add-Path "$MONGODB_HOME\bin"

# �v���O���~���O
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

# �r���h�Ǘ�
$ANT_HOME = Get-LatestPath "$APPSDIR\apache-ant*"
Add-Path "$ANT_HOME\bin"
#$Env:ANT_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"

$MVN_HOME = Get-LatestPath "$APPSDIR\apache-maven*"
Add-Path "$MVN_HOME\bin"

$GRADLE_HOME = Get-LatestPath "$APPSDIR\gradle*"
Add-Path "$GRADLE_HOME\bin"

Add-Path "$Env:HOME\.sbt"

Add-Path "$Env:HOME\.lein"

# ���̑�
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
