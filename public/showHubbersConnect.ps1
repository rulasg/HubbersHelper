function Show-HubberConnect {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$FromHandle,
        [Parameter(Mandatory, Position = 1)][string]$ToHandle
    )

    $fromHubber = Get-Hubber -Handle $FromHandle
    if ($null -eq $fromHubber) {
        Write-Error "Hubber with handle '$FromHandle' not found"
        return
    }

    $toHubber = Get-Hubber -Handle $ToHandle
    if ($null -eq $toHubber) {
        Write-Error "Hubber with handle '$ToHandle' not found"
        return
    }

    $commonHubber = Find-CommonHubber -FromHubber $fromHubber -ToHubber $toHubber

    $rootFrom = Get-TopRootHubber -Hubber $fromHubber
    $rootTo = Get-TopRootHubber -Hubber $toHubber

    $usingVirtualHolder = $false

    if ($null -eq $commonHubber) {
        $usingVirtualHolder = $true
        $holder = New-MicrosoftHolder
        $rootHubber = $holder
        $commonHubber = $holder

        $pathRootToLca = @($holder)
        $pathRootToFrom = @($holder) + (Get-PathFromAncestor -Leaf $fromHubber -Ancestor $rootFrom)
        $pathRootToTo = @($holder) + (Get-PathFromAncestor -Leaf $toHubber -Ancestor $rootTo)
        $pathLcaToFrom = $pathRootToFrom
        $pathLcaToTo = $pathRootToTo
    } else {
        $rootHubber = Get-TopRootHubber -Hubber $fromHubber

        $pathRootToLca = Get-PathFromAncestor -Leaf $commonHubber -Ancestor $rootHubber
        $pathLcaToFrom = Get-PathFromAncestor -Leaf $fromHubber -Ancestor $commonHubber
        $pathLcaToTo = Get-PathFromAncestor -Leaf $toHubber -Ancestor $commonHubber
        $pathRootToFrom = Get-PathFromAncestor -Leaf $fromHubber -Ancestor $rootHubber
        $pathRootToTo = Get-PathFromAncestor -Leaf $toHubber -Ancestor $rootHubber
    }

    $highlightEdges = @{}
    Add-PathEdgesToHighlight -Path $pathLcaToFrom -HighlightEdges $highlightEdges
    Add-PathEdgesToHighlight -Path $pathLcaToTo -HighlightEdges $highlightEdges

    $targetLogins = @{
        "$($fromHubber.github_login)" = $true
        "$($toHubber.github_login)" = $true
    }

    Write-HubbersConnectLine -PrefixSegments @() -Branch "- " -Hubber $rootHubber -HighlightBranch $false -TargetLogins $targetLogins

    $state = @{
        RootToLca = $pathRootToLca
        LcaToFrom = $pathLcaToFrom
        LcaToTo = $pathLcaToTo
        CommonNodeLogin = "$($commonHubber.github_login)"
        HighlightEdges = $highlightEdges
        TargetLogins = $targetLogins
        ExpandBranchesFromLca = (-not $usingVirtualHolder)
    }

    Show-HubbersConnectChildren -CurrentNode $rootHubber -PrefixSegments @() -State $state
} Export-ModuleMember -Function Show-HubberConnect

function Get-TopRootHubber {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Hubber
    )

    $node = $Hubber
    while ($null -ne $node.manager) {
        $node = $node.manager
    }

    return $node
}

function New-MicrosoftHolder {
    [CmdletBinding()]
    param()

    return [pscustomobject]@{
        name = 'MICROSOFT'
        title = 'Holder'
        totalReports = ''
        github_login = 'microsoft'
        reports = @{}
        manager = $null
        level = -1
    }
}

function Find-CommonHubber {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$FromHubber,
        [Parameter(Mandatory)][object]$ToHubber
    )

    $fromAncestors = @{}
    $node = $FromHubber
    while ($null -ne $node) {
        $fromAncestors["$($node.github_login)"] = $node
        $node = $node.manager
    }

    $node = $ToHubber
    while ($null -ne $node) {
        $login = "$($node.github_login)"
        if ($fromAncestors.ContainsKey($login)) {
            return $node
        }
        $node = $node.manager
    }

    return $null
}

function Get-PathFromAncestor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Leaf,
        [Parameter(Mandatory)][object]$Ancestor
    )

    $path = @()
    $node = $Leaf

    while ($null -ne $node) {
        $path += $node
        if ("$($node.github_login)" -eq "$($Ancestor.github_login)") {
            break
        }
        $node = $node.manager
    }

    [array]::Reverse($path)

    $normalizedPath = $path | ForEach-Object { [pscustomobject]$_ }
    return @($normalizedPath)
}

function Show-HubbersConnectChildren {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$CurrentNode,
        [Parameter()][array]$PrefixSegments = @(),
        [Parameter(Mandatory)][hashtable]$State
    )

    $children = Get-DisplayedChildren -CurrentNode $CurrentNode -State $State
    if ($children.Count -eq 0) {
        return
    }

    $showSpacer = Test-ShouldShowSpacerAfterNode -NodeLogin "$($CurrentNode.github_login)" -State $State
    if ($showSpacer) {
        Write-HubbersConnectSpacer -PrefixSegments $PrefixSegments -HighlightConnector $true
    }

    for ($i = 0; $i -lt $children.Count; $i++) {
        $child = $children[$i]
        if ($null -eq $child) {
            continue
        }

        $isLast = $i -eq ($children.Count - 1)
        $branch = $isLast ? "└─ " : "├─ "
        $currentLogin = "$($CurrentNode.github_login)"
        $childLogin = "$($child.github_login)"
        $edgeKey = "{0}>{1}" -f $currentLogin, $childLogin
        $highlightBranch = $State.HighlightEdges.ContainsKey($edgeKey)

        Write-HubbersConnectLine -PrefixSegments $PrefixSegments -Branch $branch -Hubber $child -HighlightBranch $highlightBranch -TargetLogins $State.TargetLogins

        $segmentText = $isLast ? "    " : "│   "
        $nextSegment = [pscustomobject]@{
            Text = $segmentText
            Highlight = $highlightBranch
        }

        $childPrefixSegments = @($PrefixSegments + @($nextSegment))
        Show-HubbersConnectChildren -CurrentNode $child -PrefixSegments $childPrefixSegments -State $State

        if (("$($CurrentNode.github_login)" -eq $State.CommonNodeLogin) -and (-not $isLast)) {
            Write-HubbersConnectSpacer -PrefixSegments $PrefixSegments -HighlightConnector $true
        }
    }
}

function Add-PathEdgesToHighlight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Path,
        [Parameter(Mandatory)][hashtable]$HighlightEdges
    )

    if ($null -eq $Path -or $Path.Count -lt 2) {
        return
    }

    for ($i = 0; $i -lt ($Path.Count - 1); $i++) {
        $parentLogin = "$($Path[$i].github_login)"
        $childLogin = "$($Path[$i + 1].github_login)"
        $edgeKey = "{0}>{1}" -f $parentLogin, $childLogin
        $HighlightEdges[$edgeKey] = $true
    }
}

function Get-DisplayedChildren {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$CurrentNode,
        [Parameter(Mandatory)][hashtable]$State
    )

    $currentLogin = "$($CurrentNode.github_login)"

    if ($currentLogin -eq $State.CommonNodeLogin) {
        $children = New-Object System.Collections.Generic.List[object]
        $nextFrom = Get-NextPathNode -Path $State.LcaToFrom -CurrentLogin $currentLogin
        $nextTo = Get-NextPathNode -Path $State.LcaToTo -CurrentLogin $currentLogin

        if ($null -ne $nextFrom) {
            $children.Add($nextFrom)
        }

        if ($null -ne $nextTo -and "$($nextTo.github_login)" -ne "$($nextFrom.github_login)") {
            $children.Add($nextTo)
        }

        return $children.ToArray()
    }

    $nextOnRootLca = Get-NextPathNode -Path $State.RootToLca -CurrentLogin $currentLogin
    if ($null -ne $nextOnRootLca) {
        return ,$nextOnRootLca
    }

    $nextOnFrom = Get-NextPathNode -Path $State.LcaToFrom -CurrentLogin $currentLogin
    if ($null -ne $nextOnFrom) {
        if ($State.ExpandBranchesFromLca) {
            return Get-AllReportsValues -Node $CurrentNode
        }

        return ,$nextOnFrom
    }

    $nextOnTo = Get-NextPathNode -Path $State.LcaToTo -CurrentLogin $currentLogin
    if ($null -ne $nextOnTo) {
        if ($State.ExpandBranchesFromLca) {
            return Get-AllReportsValues -Node $CurrentNode
        }

        return ,$nextOnTo
    }

    return @()
}

function Get-AllReportsValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Node
    )

    if ($null -eq $Node.reports -or $Node.reports.Count -eq 0) {
        return @()
    }

    $values = $Node.reports.Values | Where-Object { $null -ne $_ } | ForEach-Object { [pscustomobject]$_ }
    return @($values)
}

function Test-ShouldShowSpacerAfterNode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$NodeLogin,
        [Parameter(Mandatory)][hashtable]$State
    )

    if ($NodeLogin -eq $State.CommonNodeLogin) {
        return $true
    }

    return $false
}

function Get-NextPathNode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Path,
        [Parameter(Mandatory)][string]$CurrentLogin
    )

    for ($i = 0; $i -lt $Path.Count; $i++) {
        if ("$($Path[$i].github_login)" -eq $CurrentLogin) {
            if ($i -lt ($Path.Count - 1)) {
                return $Path[$i + 1]
            }
            return $null
        }
    }

    return $null
}

function Write-HubbersConnectLine {
    [CmdletBinding()]
    param(
        [Parameter()][array]$PrefixSegments = @(),
        [Parameter(Mandatory)][string]$Branch,
        [Parameter(Mandatory)][object]$Hubber,
        [Parameter()][bool]$HighlightBranch = $false,
        [Parameter()][hashtable]$TargetLogins
    )

    foreach ($segment in $PrefixSegments) {
        $segmentColor = $segment.Highlight ? 'Magenta' : 'Green'
        Write-Host $segment.Text -NoNewline -ForegroundColor $segmentColor
    }

    $branchColor = $HighlightBranch ? 'Magenta' : 'Green'
    $nameColor = 'White'

    if ($null -ne $TargetLogins -and $TargetLogins.ContainsKey("$($Hubber.github_login)")) {
        $nameColor = 'Magenta'
    }

    Write-Host $Branch -NoNewline -ForegroundColor $branchColor
    Write-Host "$($Hubber.name)" -NoNewline -ForegroundColor $nameColor
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.title)" -NoNewline -ForegroundColor Cyan
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.totalReports)" -NoNewline -ForegroundColor DarkRed
    Write-Host " | " -NoNewline
    Write-Host "$($Hubber.github_login)" -ForegroundColor Yellow
}

function Write-HubbersConnectSpacer {
    [CmdletBinding()]
    param(
        [Parameter()][array]$PrefixSegments = @(),
        [Parameter()][bool]$HighlightConnector = $false
    )

    foreach ($segment in $PrefixSegments) {
        $segmentColor = $segment.Highlight ? 'Magenta' : 'Green'
        Write-Host $segment.Text -NoNewline -ForegroundColor $segmentColor
    }

    $connectorColor = $HighlightConnector ? 'Magenta' : 'Green'
    Write-Host "│" -ForegroundColor $connectorColor
}
