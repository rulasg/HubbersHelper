function Show-Hubber {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Handle
    )

    $hubber = Get-Hubber -Handle $Handle

    if ($null -eq $hubber) {
        Write-Error "Hubber with handle '$Handle' not found"
        return
    }

    Write-Host ""
    Display-HubberCard -Hubber $hubber

    if ($null -ne $hubber.reports -and $hubber.reports.Count -gt 0) {
        Display-DirectReports -Reports $hubber.reports
    } else {
        Write-Host "    └─ No direct reports"
    }

    Write-Host ""
} Export-ModuleMember -Function Show-Hubber

function Display-HubberCard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Hubber
    )

    $sideMargin = 1
    $borderChars = 2
    $headerPrefix = "┌── "
    $headerSuffix = " ──┐"

    $nameText = "$($Hubber.name)"
    $titleText = "$($Hubber.title)"
    $reportsText = "$($Hubber.totalReports)"
    $loginText = "$($Hubber.github_login)"
    $separator = " | "

    $headerContentLength = $nameText.Length + $separator.Length + $titleText.Length + $separator.Length + $reportsText.Length + $separator.Length + $loginText.Length

    $labels = @(
        "manager",
        "cost_center",
        "sequenceNumber",
        "employment_type",
        "email",
        "level",
        "msft_alias",
        "country"
    )

    $labelWidth = ($labels | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

    $manager = $Hubber.manager
    $managerName = ($null -ne $manager) ? "$($manager.name)" : "N/A"
    $managerTitle = ($null -ne $manager) ? "$($manager.title)" : ""
    $managerReports = ($null -ne $manager) ? "$($manager.totalReports)" : ""
    $managerLogin = ($null -ne $manager) ? "$($manager.github_login)" : ""

    $bodyContentLengths = @(
        ($labelWidth + 2 + $managerName.Length),
        ($labelWidth + 2 + $managerTitle.Length),
        ($labelWidth + 2 + $managerReports.Length),
        ($labelWidth + 2 + $managerLogin.Length),
        ($labelWidth + 2 + ("$($Hubber.cost_center)").Length),
        ($labelWidth + 2 + ("$($Hubber.sequenceNumber)").Length),
        ($labelWidth + 2 + ("$($Hubber.employment_type)").Length),
        ($labelWidth + 2 + ("$($Hubber.email)").Length),
        ($labelWidth + 2 + ("$($Hubber.level)").Length),
        ($labelWidth + 2 + ("$($Hubber.msft_alias)").Length),
        ($labelWidth + 2 + ("$($Hubber.country)").Length)
    )

    $maxBodyContentLength = ($bodyContentLengths | Measure-Object -Maximum).Maximum
    $requiredInnerForHeader = $headerContentLength - $borderChars + $headerPrefix.Length + $headerSuffix.Length
    $requiredInnerForBody = $maxBodyContentLength + ($sideMargin * 2)
    $innerWidth = [Math]::Max($requiredInnerForHeader, $requiredInnerForBody)

    Write-ColoredHubberLine -Prefix $headerPrefix -Hubber $Hubber -Suffix $headerSuffix -TotalWidth ($innerWidth + $borderChars)

    Write-BoxEmptyLine -InnerWidth $innerWidth -SideMargin $sideMargin

    if ($null -ne $manager) {
        Write-BoxKeyValueLine -Label "manager" -Value "$($manager.name)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
        Write-BoxContinuationLine -Value "$($manager.title)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor Cyan
        Write-BoxContinuationLine -Value "$($manager.totalReports)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor DarkRed
        Write-BoxContinuationLine -Value "$($manager.github_login)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor Yellow
    } else {
        Write-BoxKeyValueLine -Label "manager" -Value "N/A" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    }

    Write-BoxEmptyLine -InnerWidth $innerWidth -SideMargin $sideMargin

    Write-BoxKeyValueLine -Label "cost_center" -Value "$($Hubber.cost_center)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "sequenceNumber" -Value "$($Hubber.sequenceNumber)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "employment_type" -Value "$($Hubber.employment_type)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "email" -Value "$($Hubber.email)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "level" -Value "$($Hubber.level)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "msft_alias" -Value "$($Hubber.msft_alias)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White
    Write-BoxKeyValueLine -Label "country" -Value "$($Hubber.country)" -InnerWidth $innerWidth -SideMargin $sideMargin -LabelWidth $labelWidth -ValueColor White

    Write-BoxEmptyLine -InnerWidth $innerWidth -SideMargin $sideMargin

    Write-Host ("└" + ("─" * $innerWidth) + "┘") -ForegroundColor Green
}

function Display-DirectReports {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Reports
    )

    $values = @($Reports.Values)

    for ($i = 0; $i -lt $values.Count; $i++) {
        $report = $values[$i]
        $symbol = ($i -eq ($values.Count - 1)) ? "└─" : "├─"
        Write-ColoredHubberLine -Prefix ("    " + $symbol + " ") -Hubber $report
    }
}

function Write-ColoredHubberLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prefix,
        [Parameter(Mandatory)][object]$Hubber,
        [Parameter()][string]$Suffix,
        [Parameter()][int]$TotalWidth = 0
    )

    $nameText = "$($Hubber.name)"
    $titleText = "$($Hubber.title)"
    $reportsText = "$($Hubber.totalReports)"
    $loginText = "$($Hubber.github_login)"
    $separator = " | "

    if ($TotalWidth -gt 0 -and -not [string]::IsNullOrEmpty($Suffix)) {
        $availableContent = $TotalWidth - $Prefix.Length - $Suffix.Length
        if ($availableContent -lt 0) {
            $availableContent = 0
        }

        $fullContent = "$nameText$separator$titleText$separator$reportsText$separator$loginText"
        if ($fullContent.Length -gt $availableContent) {
            $minTail = ($separator + $reportsText + $separator + $loginText)
            $maxNameTitle = $availableContent - $minTail.Length - $separator.Length
            if ($maxNameTitle -lt 0) {
                $maxNameTitle = 0
            }

            $nameAndTitle = "$nameText$separator$titleText"
            if ($nameAndTitle.Length -gt $maxNameTitle) {
                if ($maxNameTitle -gt 3) {
                    $nameAndTitle = $nameAndTitle.Substring(0, $maxNameTitle - 3) + "..."
                } else {
                    $nameAndTitle = "".PadRight($maxNameTitle)
                }
            }

            $fullContent = "$nameAndTitle$separator$reportsText$separator$loginText"
            if ($fullContent.Length -gt $availableContent) {
                $fullContent = $fullContent.Substring(0, $availableContent)
            }
        }

        $fullContent = $fullContent.PadRight($availableContent)

        $segments = $fullContent -split ' \| ', 4
        while ($segments.Count -lt 4) {
            $segments += ""
        }

        Write-Host $Prefix -NoNewline -ForegroundColor Green
        Write-Host $segments[0] -NoNewline -ForegroundColor White
        Write-Host $separator -NoNewline
        Write-Host $segments[1] -NoNewline -ForegroundColor Cyan
        Write-Host $separator -NoNewline
        Write-Host $segments[2] -NoNewline -ForegroundColor DarkRed
        Write-Host $separator -NoNewline
        Write-Host $segments[3] -NoNewline -ForegroundColor Yellow
        Write-Host $Suffix -ForegroundColor Green
        return
    }

    Write-Host $Prefix -NoNewline -ForegroundColor Green
    Write-Host $nameText -NoNewline -ForegroundColor White
    Write-Host $separator -NoNewline
    Write-Host $titleText -NoNewline -ForegroundColor Cyan
    Write-Host $separator -NoNewline
    Write-Host $reportsText -NoNewline -ForegroundColor DarkRed
    Write-Host $separator -NoNewline
    Write-Host $loginText -NoNewline -ForegroundColor Yellow

    if (-not [string]::IsNullOrEmpty($Suffix)) {
        Write-Host $Suffix -ForegroundColor Green
    } else {
        Write-Host ""
    }
}

function Write-BoxEmptyLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$InnerWidth,
        [Parameter()][int]$SideMargin = 0
    )

    $contentWidth = $InnerWidth - ($SideMargin * 2)
    if ($contentWidth -lt 0) {
        $contentWidth = 0
    }

    Write-Host "│" -NoNewline -ForegroundColor Green
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }
    Write-Host ((" " * $contentWidth)) -NoNewline
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }
    Write-Host "│" -ForegroundColor Green
}

function Write-BoxKeyValueLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter()][string]$Value,
        [Parameter(Mandatory)][int]$InnerWidth,
        [Parameter()][int]$SideMargin = 0,
        [Parameter(Mandatory)][int]$LabelWidth,
        [Parameter()][string]$ValueColor = "White"
    )

    if ($null -eq $Value) {
        $Value = ""
    }

    $contentWidth = $InnerWidth - ($SideMargin * 2)
    if ($contentWidth -lt 0) {
        $contentWidth = 0
    }

    $labelText = ("{0,-$labelWidth}: " -f $Label)
    $availableValueWidth = $contentWidth - $labelText.Length
    $valueText = $Value

    if ($availableValueWidth -lt 0) {
        $availableValueWidth = 0
    }

    if ($valueText.Length -gt $availableValueWidth) {
        $valueText = $valueText.Substring(0, $availableValueWidth)
    }

    $paddingSize = $contentWidth - $labelText.Length - $valueText.Length

    Write-Host "│" -NoNewline -ForegroundColor Green
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }
    Write-Host $labelText -NoNewline -ForegroundColor Green
    Write-Host $valueText -NoNewline -ForegroundColor $ValueColor

    if ($paddingSize -gt 0) {
        Write-Host ((" " * $paddingSize)) -NoNewline
    }
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }

    Write-Host "│" -ForegroundColor Green
}

function Write-BoxContinuationLine {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Value,
        [Parameter(Mandatory)][int]$InnerWidth,
        [Parameter()][int]$SideMargin = 0,
        [Parameter(Mandatory)][int]$LabelWidth,
        [Parameter()][string]$ValueColor = "White"
    )

    if ($null -eq $Value) {
        $Value = ""
    }

    $contentWidth = $InnerWidth - ($SideMargin * 2)
    if ($contentWidth -lt 0) {
        $contentWidth = 0
    }

    $prefix = ("{0}  " -f (" " * $labelWidth))
    $availableValueWidth = $contentWidth - $prefix.Length
    $valueText = $Value

    if ($availableValueWidth -lt 0) {
        $availableValueWidth = 0
    }

    if ($valueText.Length -gt $availableValueWidth) {
        $valueText = $valueText.Substring(0, $availableValueWidth)
    }

    $paddingSize = $contentWidth - $prefix.Length - $valueText.Length

    Write-Host "│" -NoNewline -ForegroundColor Green
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }
    Write-Host $prefix -NoNewline
    Write-Host $valueText -NoNewline -ForegroundColor $ValueColor

    if ($paddingSize -gt 0) {
        Write-Host ((" " * $paddingSize)) -NoNewline
    }
    if ($SideMargin -gt 0) {
        Write-Host ((" " * $SideMargin)) -NoNewline
    }

    Write-Host "│" -ForegroundColor Green
}
