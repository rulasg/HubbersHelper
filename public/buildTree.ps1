function Build-Tree {
    [cmdletbinding()]
    param (

    )

    $hubbers = Get-Hubber -AsHashtable

    $ceo = $hubbers.Values | Where-Object { $_.manager -eq $_.github_login }

    $tree = Build-Node $hubbers $ceo

    $global:hubbers = $hubbers
    $global:tree = $tree

    return $hubbers, $tree

} Export-ModuleMember -Function Build-Tree


function Build-Node {
    param(
        [Parameter(Mandatory, Position = 1)][object]$hubbers,
        [Parameter(Mandatory, Position = 2)][object]$Node
    )

    try {

        Write-Host "." -NoNewline

        # Stop after X nodes
        if (! (Test-Continue)) {
            $Node.count = -1
            return $Node
        }

        $nlogin = $Node.github_login

        ## Manager
        # Set to null the manager for the CEO where manager == him self
        $node.manager = ($node.manager -ne $nlogin) ? $hubbers.$($node.manager) : $null

        ## Employees

        $employeesList = $hubbers.Values | Where-Object { ($_.manager -eq $nlogin) -and ($_.github_login -ne $nlogin) }

        $Node.totalEmployees = 0

        # Recurse employ
        if ($employeesList.count -ne 0) {

            $Node.employees = @{}

            # recurse call
            foreach ($employee in $employeesList) {

                $elogin = $employee.github_login

                if( $null -eq $elogin -or [string]::IsNullOrWhiteSpace($elogin) ){
                    Write-Warning -Message "Skipping employee name [$($employee.name)] with empty github_login under manager $nlogin"
                    Write-Verbose -message "$($employee | convertto-Json -Depth 10) "
                    continue
                }

                $Node.employees.$elogin = Build-Node $hubbers $employee
            }
        
            # Count the number of employees under this node
            foreach ($employee in $Node.employees.Values) {
                if ($null -ne $employee.totalEmployees) {
                    $Node.totalEmployees += $employee.totalEmployees
                }
                $Node.totalEmployees++
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