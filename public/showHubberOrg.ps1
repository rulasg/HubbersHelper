function Show-HubberOrg {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Handle,
        [Parameter()][int]$Depth = 0
    )

    $hubber = Get-Hubber -Handle $Handle

    if ($null -eq $hubber) {
        Write-Error "Hubber with handle '$Handle' not found"
        return
    }

    Write-HubberOrgLine -Prefix "- " -Hubber $hubber

    if ($Depth -lt 0) {
        Write-Error "Depth must be zero or greater"
        return
    }

    if ($null -ne $hubber.reports -and $hubber.reports.Count -gt 0) {
        if (($Depth -eq 0) -or ($Depth -gt 1)) {
            Write-HubberOrgSpacer -Prefix "    │"
        }
        Show-HubberOrgChildren -Reports $hubber.reports -Prefix "    " -DepthRemaining $Depth
    }
} Export-ModuleMember -Function Show-HubberOrg

function Show-HubberOrgChildren {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Reports,
        [Parameter(Mandatory)][string]$Prefix,
        [Parameter(Mandatory)][int]$DepthRemaining
    )

    $values = @($Reports.Values)

    for ($i = 0; $i -lt $values.Count; $i++) {
        $report = $values[$i]
        $isLast = $i -eq ($values.Count - 1)
        $branch = $isLast ? "└─ " : "├─ "

        Write-HubberOrgLine -Prefix ($Prefix + $branch) -Hubber $report

        $shouldRecurse = (($DepthRemaining -eq 0) -or ($DepthRemaining -gt 1)) -and ($null -ne $report.reports) -and ($report.reports.Count -gt 0)

        if ($shouldRecurse) {
            $childPrefix = $Prefix + ($(if ($isLast) { "    " } else { "│   " }))
            $nextDepth = ($DepthRemaining -eq 0) ? 0 : ($DepthRemaining - 1)
            Show-HubberOrgChildren -Reports $report.reports -Prefix $childPrefix -DepthRemaining $nextDepth

            if (-not $isLast) {
                Write-HubberOrgSpacer -Prefix ($Prefix + "│")
            }
        }
    }
}

function Write-HubberOrgLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prefix,
        [Parameter(Mandatory)][object]$Hubber
    )

    Write-Host $Prefix -NoNewline -ForegroundColor Green
    Write-Host "$($Hubber.name)" -NoNewline -ForegroundColor White
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.title)" -NoNewline -ForegroundColor Cyan
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.totalReports)" -NoNewline -ForegroundColor DarkRed
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.github_login)" -ForegroundColor Yellow
}

function Write-HubberOrgSpacer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prefix
    )

    Write-Host $Prefix -ForegroundColor Green
}
