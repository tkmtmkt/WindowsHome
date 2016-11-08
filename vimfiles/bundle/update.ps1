<#
.SYNOPSIS
#>
$ps1_file = $MyInvocation.MyCommand.Path
$base_dir = split-path $ps1_file
$log_file = $ps1_file.replace(".ps1",".log")

ls $base_dir .git -r -fo | %{
    $repo_dir = split-path $_.fullname
    write-host "### $(split-path $repo_dir -leaf)"
    pushd $repo_dir
    git co master
    git fetch --all
    git pull
    popd
}
# vim: set ts=4 sw=4 et :
