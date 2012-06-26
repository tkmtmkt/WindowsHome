<#
.SYNOPSIS

.PARAMETER Path

#>
function Connect-SQLite
{
    param(
        [parameter(Mandatory=$true, Position=0)]
        [string]
        $Path
    )

    $cn = "Data Source=$Path"
    try {
        if ($global:con -eq $null) {
            $global:con = New-Object Data.SQLite.SQLiteConnection($cn)
            $global:con.Open()
        } elseif ($global:con.State -ne 'Open') {
            $global:con.ConnectionString = $cn
            $global:con.Open()
        }
        $global:con
    } catch {
        Write-Host $_
    }
}
# vim: set ts=4 sw=4 et:
