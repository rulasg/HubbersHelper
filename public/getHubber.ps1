
function Get-Hubber{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][string]$Handle,
        [Parameter()][switch]$AsHashtable
    )

    $hubbers = Get-HubbersList

    $ret = $hubbers.$Handle

    return [PSCustomObject] $ret

} Export-ModuleMember -Function Get-Hubber