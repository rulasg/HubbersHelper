
Set-MyInvokeCommandAlias -Alias GetHubbers -Command "Invoke-GetHubbers"

function Get-Hubber{
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Handle,
        [Parameter()][switch]$AsHashtable
    )

    $hubbers = Invoke-MyCommand -Command GetHubbers

    if(! [string]::IsNullOrWhiteSpace($Handle)){
        return [pscustomobject] $hubbers.$Handle
    }

    if($AsHashtable){
        return $hubbers
    } else {
        return $hubbers.Values
    }
} Export-ModuleMember -Function Get-Hubber

function Get-HubberByCountry {
    param (
        [string]$Country
    )

    $hubbers = Invoke-MyCommand -Command GetHubbers

    $ret = $hubbers.Values | Where-Object { $_.country -eq $Country }

    return $ret

} Export-ModuleMember -Function Get-HubberByCountry

function Invoke-GetHubbers {
    [CmdletBinding()]
    param()

    # Downloaded from https://thehub.github.com/assets/org-data.json
    $path = "~/hubbers.json"

    $hubbers = Get-Content -Path $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $hubbers
} Export-ModuleMember -Function Invoke-GetHubbers