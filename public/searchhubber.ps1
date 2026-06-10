function Search-Hubber {
    [CmdletBinding()]
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