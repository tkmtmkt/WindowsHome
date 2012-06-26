<#
.SYNOPSIS

.PARAMETER Path

#>
function Disconnect-SQLite
{
    try {
        $global:con.Close()
        $global:con.Dispose()
        $global:con = $null
    } catch {
        Write-Host $_
    }
}
# vim: set ts=4 sw=4 et:
