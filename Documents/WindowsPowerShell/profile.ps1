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
$TOOLDIR = "$Env:HOME\tool"
$APPSDIR = "$Env:HOME\apps"
$BASEDIR = "$Env:HOME\work"
function TODAYPATH {"$BASEDIR\$(date -f 'yyyy\\MM\\yyyyMMdd')"}
$WORKDIR = (TODAYPATH)

# �R���\�[���ݒ�
$Host.UI.RawUI | %{
    $height = $_.MaxPhysicalWindowSize.Height - 2
    $_.WindowSize = new-object Management.Automation.Host.Size(120, $height)
    $_.BufferSize = new-object Management.Automation.Host.Size(120, 3000)
    $_.ForegroundColor = "White"
    $_.BackgroundColor = "Black"
    cls
}

# �v�����v�g�ݒ�
function prompt {
    write-host "$($Env:USERDOMAIN)\$($Env:USERNAME) " -NoNewline -ForegroundColor "Green"
    write-host "$PWD" -ForegroundColor "DarkCyan"
    $(if (test-path Variable:/PSDebugContext) { '[DBG]: ' } else { '' }) +
    "PS $(date -f 'yyyy/MM/dd HH:mm:ss')$('>' * ($NestedPromptLevel + 1)) "
}

# �V���[�g�J�b�g�FSSH�ڑ�
function ssh-sakura {ttermpro $Env:USERNAME@www.sakura.ne.jp /P=22 /L=$(log "sakura-")}

# �V���[�g�J�b�g�F�h���C�u�w��
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
        �t�H���_�ւ̃V���[�g�J�b�g�p�h���C�u�Ɉړ����܂��B
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
# �֐���`
#
############################################################
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
    if (-not (test-path (TODAYPATH))) {
        new-item (TODAYPATH) -type dir -force | out-null
    }
    "$(TODAYPATH)\$(if ($id -ne $null) {"$id"})$(date -f 'yyyyMMddHHmmss').log"
}

<#
.SYNOPSIS
��ƋL�^�������J���܂��B
#>
Function memo {
    $file = "$WORKDIR.mkd"
    If (-not (Test-Path $file)) {
        If (-not (Test-Path (Split-Path $file))) {
            new-item (Split-Path $file) -type dir -force | Out-Null
        }
@" 
��ƋL�^
========
�J�n�F$(date -f 'yyyy/MM/dd HH:mm')  
�I���F

�\��
----
* 


����
----

### 










����
----





�Q�l
----
* [Markdown�̕��@](http://blog.2310.net/archives/6)

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
�ЂƂO�̍�ƋL�^�������J���܂��B
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

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
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
.PARAMETER hashAlgorithm
�n�b�V���A���S���Y�����w�肵�܂��B
.PARAMETER filePath
�t�@�C���p�X���w�肵�܂��B
#>
Function Get-Hash {
    Param (
        [parameter(Mandatory=$true)][Security.Cryptography.HashAlgorithm]$hashAlgorithm,
        [parameter(Mandatory=$true)][string]$fileName
    )

    # �n�b�V���쐬
    $inputStream = New-Object IO.StreamReader $fileName
    $hash = $hashAlgorithm.ComputeHash($inputStream.BaseStream);
    $inputStream.Close()

    # ������ɕϊ�
    [BitConverter]::ToString($hash).ToLower().Replace("-","")
}

<#
.SYNOPSIS
�w�肵���t�@�C����MD5�n�b�V�����擾���܂��B
.PARAMETER filePath
�t�@�C���p�X���w�肵�܂��B
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
�w�肵���t�@�C����SHA1�n�b�V�����擾���܂��B
.PARAMETER filePath
�t�@�C���p�X���w�肵�܂��B
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

    @(ls "$Path" -ea SilentlyContinue | sort -desc)[0].fullname
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
sbt�̏����v���W�F�N�g���쐬����B
#>
function sbt-init {
    # �����f�B���N�g���쐬
@" 
project
lib
src
src/main
src/main/scala
src/test
src/test/scala
"@ -split "`r*`n" | %{md $_}

    # �r���h�ݒ�t�@�C���쐬
    $build_file = "build.sbt"
@" 

name := "My Project"

version := "0.1-SNAPSHOT"

organization := "home"

libraryDependencies += "junit" % "junit" % "4.8" % "test"
"@ | out-file $build_file -encoding UTF8

    # �T���v���\�[�X�t�@�C���쐬
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

$SVN_HOME = Get-LatestPath "$APPSDIR\svn*"
Add-Path "$SVN_HOME\bin"

$VERACITY_HOME = Get-LatestPath "$APPSDIR\vv_*"
Add-Path "$VERACITY_HOME"

# �f�[�^�x�[�X
$MONGODB_HOME = Get-LatestPath "$APPSDIR\mongodb*"
Add-Path "$MONGODB_HOME\bin"

# �v���O���~���O
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

# �r���h�Ǘ�
$ANT_HOME = Get-LatestPath "$APPSDIR\apache-ant*"
Add-Path "$ANT_HOME\bin"

$MVN_HOME = Get-LatestPath "$APPSDIR\apache-maven*"
Add-Path "$MVN_HOME\bin"

# ���̑�
$PANDOC_HOME = Get-LatestPath "$APPSDIR\pandoc*"
Add-Path "$PANDOC_HOME\bin"

Add-Path "$APPSDIR\astah_community"

Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
