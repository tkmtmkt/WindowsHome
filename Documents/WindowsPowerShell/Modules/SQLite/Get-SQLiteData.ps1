<#
.SYNOPSIS

.PARAMETER Table

.PARAMETER Query

#>
function Get-SQLiteData
{
    param(
        [parameter(Mandatory=$true, Position=0, ParameterSetName="Table")]
        [string]$Table = $null,
        [parameter(Mandatory=$true, ParameterSetName="SQL")]
        [string]$Query
    )

    try {
        $cmd = $global:con.CreateCommand()
        if ($Table -ne $null) {
            $cmd.CommandText = "SELECT * FROM $Table"
        } else {
            $cmd.CommandText = $Query
        }

        $reader = $cmd.ExecuteReader()
        $reader | %{
            $record = $_
            $data = New-Object PSObject
            foreach ($i in 0..($record.FieldCount - 1)) {
                Add-Member NoteProperty $record.GetName($i) $record.GetValue($i) -InputObject $data
            }
            $data
        }
        $cmd.Dispose()
    } catch {
        Write-Host $_
    }
}
# vim: set ts=4 sw=4 et:
