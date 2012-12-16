<#
.SYNOPSIS
#>
$ps1_file = $MyInvocation.MyCommand.Path
$log_file = $ps1_file.replace(".ps1",".log")

ls | ?{$_.PsIsContainer} | %{
    "###  $($_.name)  ###"
    pushd $_.name
    git co master
    git pull
    popd
}

# vim: set ft=ps1 ts=4 sw=4 et: