############################################################
#
# ���ݒ�i���[�U��Ɨp�j
#
############################################################
$TOOLDIR = "$Home\tool"
$APPSDIR = "$Home\apps"
$TODAYPATH = "$Home\work\$(Get-Date -f "yyyy\\MM\\yyyyMMdd")"

# �R���\�[���ݒ�
$tmp = $Host.UI.RawUI.WindowSize
$tmp.Width  = 120
$Host.UI.RawUI.WindowSize = $tmp
$Host.UI.RawUI.ForegroundColor="White"
$Host.UI.RawUI.BackgroundColor="Black"
cls

# �t�H���_�ւ̃V���[�g�J�b�g�p�h���C�u�̐ݒ�
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
            New-Item (Split-Path $memo_file) -Force -ItemType Directory
        }
@" 
��ƋL�^
========
�J�n�F$(Get-Date -f "yyyy/MM/dd HH:mm")  
�I���F

�\��
----
* 
* 
* 
* 
* 

�ڍ�
----

### 





����
----





�Q�l
----
[Markdown�̕��@](http://blog.2310.net/archives/6)

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
        $out_file
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
���݂̃Z�b�V�����Ƀ��[�h���ꂽ�A�Z���u�����擾���܂��B
#>
Function Get-Assemblies
{
    [Appdomain]::CurrentDomain.GetAssemblies()
}

<#
.SYNOPSIS
���ϐ�PATH�ɐV�����p�X��ǉ����܂��B
.PARAMETER item
�ǉ�����p�X���w�肵�܂��B
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
# ���ݒ�i�c�[���j
#
############################################################
Add-Path $TOOLDIR

# �A�[�J�C�o
Add-Path "$TOOLDIR\7-Zip"
Set-Alias zip "$TOOLDIR\7-Zip\7z.exe"

# �G�f�B�^
Add-Path "$TOOLDIR\vim"
Set-Alias vi "$TOOLDIR\vim\vim.exe"

# �����c�[��
Add-Path "$TOOLDIR\WinMerge"

# �����[�g�ڑ�
Add-Path "$TOOLDIR\teraterm"
Add-Path "$TOOLDIR\winscp"
If (Test-Path "$TOOLDIR\vnc*") {
    Set-Alias vnc @(ls "$TOOLDIR\vnc*" | sort)[0].FullName
}

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
Add-Path "$APPSDIR\git"
Add-Path "$APPSDIR\git\cmd"
Add-Path "$APPSDIR\svn-win32\bin"
Add-Path "$APPSDIR\veracity"

# �f�[�^�x�[�X
Add-Path "$APPSDIR\mongodb\bin"

# �v���O���~���O
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

# �r���h�Ǘ�
Add-Path "$APPSDIR\apache-ant\bin"
Add-Path "$APPSDIR\apache-maven\bin"

# ���̑�
Add-Path "$APPSDIR\Play20"

# vim: set ft=ps1 ts=4 sw=4 et:
