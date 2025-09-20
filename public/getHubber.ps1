function Get-Hubber{
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Handle,
        [Parameter()][switch]$AsHashtable
    )

    $hubbers = Get-Content -Path "~/hubbers.json" | ConvertFrom-Json -Depth 10 -AsHashtable

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

    $path = Get-HubberJsonPath

    $hubbers = Get-Content -Path $path | ConvertFrom-Json -Depth 10 -AsHashtable

    $ret = $hubbers.Values | Where-Object { $_.country -eq $Country }

    return $ret

} Export-ModuleMember -Function Get-HubberByCountry

function Get-HubberJsonPath() {

    # Downloaded from https://thehub.github.com/assets/org-data.json
    return "~/hubbers.json"
} 