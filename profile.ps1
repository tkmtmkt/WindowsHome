############################################################
#
# �֐���`
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

############################################################
#
# ���ݒ�i�c�[���j
#
############################################################
$TOOLDIR = "$Home\tool"

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
$OPTDIR = "$Home\opt"

Add-Path "$OPTDIR\bin"

# �\���Ǘ�
Add-Path "$OPTDIR\git"
Add-Path "$OPTDIR\git\cmd"
Add-Path "$OPTDIR\svn-win32\bin"
Add-Path "$OPTDIR\veracity"

# �f�[�^�x�[�X
Add-Path "$OPTDIR\mongodb\bin"

# �v���O���~���O
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

# �r���h�Ǘ�
Add-Path "$OPTDIR\apache-ant\bin"
Add-Path "$OPTDIR\apache-maven\bin"

Add-Path "$Home"

############################################################
#
# ���ݒ�i���[�U��Ɨp�j
#
############################################################

# �R���\�[���ݒ�
$tmp = $Host.UI.RawUI.WindowSize
$tmp.Width  = 120
$tmp.Height = 35
$Host.UI.RawUI.WindowSize = $tmp
$Host.UI.RawUI.ForegroundColor="White"
$Host.UI.RawUI.BackgroundColor="Black"
cls

# ��ƃf�B���N�g���Ɉړ�����
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

# ��ƃ������J��
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
[1]: http://blog.2310.net/archives/6 "Markdown�̕��@"

<!-- vim: set ft=markdown ts=4 sw=4 et:-->
"@ | Out-File $memo_file -Encoding Default -Force
    }

    If ((Get-Command gvim -ErrorAction:SilentlyContinue) -ne $null) {
        gvim $memo_file
    } else {
        notepad $memo_file
    }
}

# �V���[�g�J�b�g�p�h���C�u�ݒ�
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
