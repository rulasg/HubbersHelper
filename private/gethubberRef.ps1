function getHubberRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$Hubber
    )

    process{
        [pscustomobject]@{
                name = $Hubber.name
                title = $Hubber.title
                totalReports = $Hubber.totalReports
                handle = $Hubber.github_login
            }
    }
}