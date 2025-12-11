function Search-Hubber {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)][string]$Name,
        [Parameter()][string]$Handle
    )

    $isName = -not [string]::IsNullOrEmpty($Name)
    $isHandle = -not [string]::IsNullOrEmpty($Handle)
    
    if( ! $isName -and ! $isHandle ) {
        Write-MyError -Message "Please specify either Name or Handle, or both."
        return $null
    }
    
    $hubbersList = Get-HubbersList

    $hubbers = $hubbersList.Values

    if ( $isHandle ) {
        $hubbers = $hubbers | Where-Object { $_.github_login -like "*$Handle*" }
    }

    if ( $isName ) {
        $hubbers = $hubbers | Where-Object { $_.name -like "*$Name*" }
    }

    # Convert to PSCustomObject
    $hubbers = $hubbers | ForEach-Object{ [pscustomobject]$_}

    return $hubbers
} Export-ModuleMember -Function Search-Hubber