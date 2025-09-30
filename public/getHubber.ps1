
function Get-Hubber{
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Handle,
        [Parameter()][switch]$AsHashtable
    )

    $hubbers = Get-HubbersList

    $ret = $hubbers.$Handle

    return $ret

} Export-ModuleMember -Function Get-Hubber