function Search-HubberV1 {
    [CmdletBinding()]
    [Alias("")]
    param (
        [Parameter(Position=0)][string]$Name,
        [Parameter()][string]$Title,
        [Parameter()][string]$Handle,
        [Parameter()][switch]$PassThru
    )

    $isFiltered = $false

    $hubbersList = Get-HubbersList

    $hubbers = $hubbersList.Values

    if ( -not [string]::IsNullOrEmpty($Handle) ) {
        $hubbers = $hubbers | Where-Object { $_.github_login -like "*$Handle*" }
        $isFiltered = $true
    }

    if (-not [string]::IsNullOrEmpty($Name) ) {
        $hubbers = $hubbers | Where-Object { $_.name -like "*$Name*" }
        $isFiltered = $true
    }

    if (-not [string]::IsNullOrEmpty($Title) ) {
        $hubbers = $hubbers | Where-Object { $_.title -like "*$Title*" }
        $isFiltered = $true
    }

    if(-Not $isfiltered){
        Write-Warning "Please provide at least one filter parameter."
        return
    }

    # Convert to PSCustomObject
    $hubbers = $hubbers | ForEach-Object{ [pscustomobject]$_}

    if($PassThru){
        return $hubbers
    } else {
        $hubbers | sort-object totalReports,name -Descending | Format-Table -Property name, title, totalReports, github_login -AutoSize
    }
} Export-ModuleMember -Function Search-Hubber

function Search-HubberV2 {
    [CmdletBinding()]
    [Alias("Search-Hubber","sbb")]
    param (
        [Parameter(Position=0)][string]$Name,
        [Parameter()][string]$Title,
        [Parameter()][switch]$PassThru
    )

    $hubbersList = Get-HubbersList

    $hubbers = $hubbersList.Values

    $ret = @()

    if (-not [string]::IsNullOrEmpty($Title) ) {
        $filterTitle = @($hubbers | Where-Object { $_.title -like "*$Title*" })
    } else {
        $filterTitle = @($hubbers)
    }

    if (-not [string]::IsNullOrEmpty($Name) ) {
        $ret += @($filterTitle | Where-Object { $_.github_login -like "*$Name*" })
        $ret += @($filterTitle | Where-Object { $_.name -like "*$Name*" })
        
        # Ensure that $ret has no duplications
        $ret = @($ret | Sort-Object -Property github_login -Unique)

    } else {
        $ret = @($filterTitle)
    }

    # return if empty
    if($ret.count -eq 0){
        return
    }

    # Convert to PSCustomObject
    $ret = $ret | ForEach-Object{ [pscustomobject]$_}

    # object or show
    if($PassThru){
        return $ret
    } else {
        # $ret | sort-object totalReports,name -Descending | Format-Table -Property name, title, totalReports, github_login -AutoSize
        foreach ($item in $ret) {
            [pscustomobject]@{
                name = $item.name
                title = $item.title
                totalReports = $item.totalReports
                handle = $item.github_login
            }
        }
    }
} Export-ModuleMember -Function Search-HubberV2 -alias "sbb","Search-Hubber"