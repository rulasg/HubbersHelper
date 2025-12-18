function Get-HubberReports {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][string]$Handle
    )

    $node = Get-Hubber -Handle $Handle

    if($null -eq $node){
        throw "Hubber with handle '$Handle' not found"
    }

    # recurse for every report
    $ret = $node.reports.values | Get-Reports

    return $ret

} Export-ModuleMember -Function Get-HubberReports

function Get-Reports{
    param (
        [Parameter(ValueFromPipeline)][object]$node
    )
    process{

        if($null -eq $node){
            return @()
        }

        $ret = @()

        $ret = $node.reports.values | Get-Reports

        $ret += $node

        return $ret
    }
}