function Build-HubbersTree {
    [cmdletbinding()]
    param (

    )

    $hubbers = Get-Hubber -AsHashtable

    $ceo = $hubbers.Values | Where-Object { $_.manager -eq $_.github_login }

    $tree = Build-Node $hubbers $ceo

    Save-HubbersListDb -Hubbers $hubbers
    Save-HubbersTreeDb -Hubbers $tree

    $global:ResultHubbersBuild = @{
        totalHubbers = $hubbers.count
        "HubbersList" = $hubbers
        "HubbersTree" = $tree
    }

    return $global:ResultHubbersBuild

} Export-ModuleMember -Function Build-HubbersTree


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