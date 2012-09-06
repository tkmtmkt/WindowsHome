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
$TODAYPATH = "$Env:HOME\work\$(Get-Date -u "%Y\%m\%Y%m%d")"

# �R���\�[���ݒ�
$Host.UI.RawUI | %{
    $tmp = $_.MaxPhysicalWindowSize
    $tmpHeight = $tmp.Height - 2
    $tmp.Width = 120
    $tmp.Height = 3000
    $_.BufferSize = $tmp
    $tmp.Height = $tmpHeight
    $_.WindowSize = $tmp

    $_.ForegroundColor = "White"
    $_.BackgroundColor = "Black"
    cls
}

# �t�H���_�ւ̃V���[�g�J�b�g�p�h���C�u�̐ݒ�
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
        �t�H���_�ւ̃V���[�g�J�b�g�p�h���C�u�Ɉړ����܂��B
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
# �֐���`
#
############################################################
<#
.SYNOPSIS
��ƋL�^�������J���܂��B
#>
Function memo
{
    $memo_file = "$TODAYPATH.mkd"
    If (-not (Test-Path $memo_file)) {
        If (-not (Test-Path (Split-Path $memo_file))) {
            New-Item (Split-Path $memo_file) -Force -ItemType Directory | Out-Null
        }
@" 
��ƋL�^
========
�J�n�F$(Get-Date -u "%Y/%m/%d %H:%M")  
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
�ЂƂO�̍�ƋL�^�������J���܂��B
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
grep���ǂ��B
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
�N���b�v�{�[�g���̉摜���t�@�C���ɏo�͂��܂��B
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
�w�肵���t�@�C����MD5�n�b�V�����擾���܂��B
.PARAMETER filePath
�t�@�C���p�X���w�肵�܂��B
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
���݂̃Z�b�V�����Ƀ��[�h���ꂽ�A�Z���u�����擾���܂��B
#>
Function Get-Assemblies
{
    [Appdomain]::CurrentDomain.GetAssemblies()
}

<#
.SYNOPSIS
�w�肵���p�X����ŐV�̍��ڂ��擾���܂��B
.PARAMETER Path
���C���h�J�[�h���܂ރp�X���w�肵�܂��B
#>
function Get-LatestPath {
    param([string]$Path)

    @(ls "$Path" -ea SilentlyContinue | sort -desc)[0].fullname
}

<#
.SYNOPSIS
���ϐ�PATH�ɐV�����p�X��ǉ����܂��B
.PARAMETER Item
�ǉ�����p�X���w�肵�܂��B
#>
Function Add-Path
{
    Param([string]$Item)

    if ($Item -eq $null -or
        $Env:PATH.ToUpper().Contains($Item.ToUpper())) {return}

    $Env:PATH += ";$Item"
}

<#
.SYNOPSIS
sbt�̏����v���W�F�N�g���쐬����B
#>
function sbt-init
{
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
function Set-CLRVersion
{
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
Set-Alias zip "$TOOLDIR\7-Zip\7z.exe"

# �G�f�B�^
$VIM_HOME = Get-LatestPath "$TOOLDIR\vim*"
Add-Path "$VIM_HOME"
Set-Alias vi "$VIM_HOME\vim.exe"

# �����c�[��
$WINMERGE_HOME = Get-LatestPath "$TOOLDIR\WinMerge*"
Add-Path "$WINMERGE_HOME"

# �����[�g�ڑ�
$TERATERM_HOME = Get-LatestPath "$TOOLDIR\teraterm*"
Add-Path "$TOOLDIR\teraterm"
$WINSCP_HOME = Get-LatestPath "$TOOLDIR\winscp*"
Add-Path "$WINSCP_HOME"

$VNC = Get-LatestPath "$TOOLDIR\vnc*"
Set-Alias vnc $VNC

# �V�X�e���Ǘ�
Add-Path "$TOOLDIR\SysinternalsSuite"
Add-Path "$TOOLDIR\Log Parser 2.2"
Add-Path "$TOOLDIR\SUPPORT"

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
$VERACITY_HOME = Get-LatestPath "$APPSDIR\veracity*"
Add-Path "$VERACITY_HOME"

# �f�[�^�x�[�X
$MONGODB_HOME = Get-LatestPath "$APPSDIR\mongodb*"
Add-Path "$MONGODB_HOME\bin"

# �v���O���~���O
$JAVA_HOME = Get-LatestPath "$Env:ProgramFiles\Java\jdk*"
Add-Path "$Env:JAVA_HOME\bin"
#$Env:JAVA_OPTS = "-Dhttp.proxyHost=proxyhostURL -Dhttp.proxyPort=proxyPortNumber"

$SCALA_HOME = Get-LatestPath "$APPSDIR\scala*"
Add-Path "$SCALA_HOME\bin"

Function sbt {
    $sbt = Get-LatestPath "$APPSDIR\bin\sbt-launch*.jar"
    If ($sbt -ne $null) {
        $argList  = @("$Env:JAVA_OPTS -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=384M")
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
Add-Path "$APPSDIR\astah_community"
Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
