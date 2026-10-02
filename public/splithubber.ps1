function Split-Hubber {
    [CmdletBinding()]
    [Alias("spbb")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][Alias("github_login")][string]$handle,
        [Parameter()][switch]$Manager,
        [Parameter()][switch]$Reports
    )

    begin{
        $retHandls = @()
    }

    process{
        $hubber = Resolve-Hubber -Handle $handle

        if($Manager){
            $mgr = $hubber.manager
            if ($mgr) {
                $retHandls += $mgr.github_login
            }
        }

        if ($Reports) {
            if ($hubber.reports) {
                $retHandls += $hubber.reports.Values.github_login
            }
        }
    }

    end{
        # return hubber refs
        $retHandls = $retHandls | Sort-Object -Unique
        foreach ($item in $retHandls) {
            Resolve-Hubber -Handle $item | getHubberRef
        }
    }
} Export-ModuleMember -Function Split-Hubber -Alias spbb