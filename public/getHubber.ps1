
Set-MyInvokeCommandAlias -Alias GetHubbers -Command "Invoke-GetHubbers"

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

function Get-HubberByCountry {
    param (
        [string]$Country
    )

    $hubbers = Invoke-MyCommand -Command GetHubbers

    $ret = $hubbers.Values | Where-Object { $_.country -eq $Country }

    return $ret

} Export-ModuleMember -Function Get-HubberByCountry