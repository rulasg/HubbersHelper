
function Import-HubbersListV2 {
    [cmdletbinding()]
    param (
        #path to hubber list
        [Parameter(Mandatory, Position = 1)][string]$Path
    )

    try{
        $hubbersRawList = Get-Content $Path -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        Write-Error -Message "Failed to read or parse JSON file: $_"
        return $null
    }

    # Calculate the tree
    $result = Build-HubbersTreeV2 -Hubbers $hubbersRawList

    # Save to local cache
    Save-HubbersListDb -Hubbers $result.HubbersList
    Save-HubbersTreeDb -Hubbers $result.HubbersTree

    return $result

} Export-ModuleMember -Function Import-HubbersListV2


function Build-HubbersTreeV2 {
    [cmdletbinding()]
    param (
        [Parameter(mandatory)][hashtable]$Hubbers
    )

    $heads = @()
    $tree = @{}

    # Find all the heads of the tree
    # nodes where the manager is themselves
    $heads += $hubbers.Values | Where-Object { $_.manager -eq $_.github_login }
    # $heads += $hubbers.Values | Where-Object { $_.manager -eq $null }

    $moreheads = $Hubbers.Keys | where-object {
        $mh = $hubbers.$_.manager
        $null -eq $hubbers.$mh
    }

    $heads += $moreheads | ForEach-Object { $hubbers.$_ }

    foreach($h in $heads){
        $hh = $h.github_login
        Write-Host ""
        Write-Host "Building tree for head: $hh"
        $result =  Build-Node $hubbers $h

        $tree.$hh = $result
    }

    $global:ResultHubbersBuild = @{
        totalHubbers = $hubbers.count
        "HubbersList" = $hubbers
        "HubbersTree" = $tree
    }

    return $global:ResultHubbersBuild

}