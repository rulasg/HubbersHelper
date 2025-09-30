
function Load-HubbersList {
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
    $result = Build-HubbersTree -Hubbers $hubbersRawList

    # Save to local cache
    Save-HubbersListDb -Hubbers $result.HubbersList
    Save-HubbersTreeDb -Hubbers $result.HubbersTree

    return $result

} Export-ModuleMember -Function Load-HubbersList


function Build-HubbersTree {
    [cmdletbinding()]
    param (
        [Parameter(mandatory)][hashtable]$Hubbers
    )

    $ceo = $hubbers.Values | Where-Object { $_.manager -eq $_.github_login }

    $tree = Build-Node $hubbers $ceo

    $global:ResultHubbersBuild = @{
        totalHubbers = $hubbers.count
        "HubbersList" = $hubbers
        "HubbersTree" = $tree
    }

    return $global:ResultHubbersBuild

}


function Build-Node {
    param(
        [Parameter(Mandatory, Position = 1)][object]$hubbers,
        [Parameter(Mandatory, Position = 2)][object]$Node
    )

    try {

        if ($null -eq $script:count -or ($script:count % 10) -eq 0) {
            Write-Host "." -NoNewline
        }

        # Stop after X nodes
        if (! (Test-Continue)) {
            $Node.count = -1
            return $Node
        }

        $nlogin = $Node.github_login

        ## Manager
        # Set to null the manager for the CEO where manager == him self
        $node.manager = ($node.manager -eq $nlogin) ? $null : $hubbers.$($node.manager)
        $node.level = $node.manager ? $node.manager.level + 1 : 0

        ## Reports

        $reportsList = $hubbers.Values | Where-Object { ($_.manager -eq $nlogin) -and ($_.github_login -ne $nlogin) }

        $Node.totalReports = 0

        # Recurse employ
        if ($reportsList.count -ne 0) {

            $Node.reports = @{}

            # recurse call
            foreach ($employee in $reportsList) {

                $elogin = $employee.github_login

                if( $null -eq $elogin -or [string]::IsNullOrWhiteSpace($elogin) ){
                    Write-Warning -Message "Skipping employee name [$($employee.name)] with empty github_login under manager $nlogin"
                    Write-Verbose -message "$($employee | convertto-Json -Depth 10) "
                    continue
                }

                $Node.reports.$elogin = Build-Node $hubbers $employee
            }
        
            # Count the number of reports under this node
            foreach ($employee in $Node.reports.Values) {
                if ($null -ne $employee.totalReports) {
                    $Node.totalReports += $employee.totalReports
                }
                $Node.totalReports++
            }
        }

        $Node.sequenceNumber = $script:count

        return $Node
    } catch {
        Write-Error -Message "Error building node for $($Node.github_login): $_"
    }
}

function Test-Continue() {

    $max = 5000
    
    if ($null -eq $script:count) {
        $script:count = 0
    }
    else {
        $script:count++
    }

    if ($script:count -gt $max) {
        return $false
    }

    # Write-Host "$script:count ." -NoNewline

    return $true
}