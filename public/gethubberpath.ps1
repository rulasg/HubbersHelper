function Get-HubberPath{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][string]$Handle
    )

    $hubber = Get-Hubber -Handle $Handle

    if($null -eq $hubber){
        throw "Hubber with handle '$Handle' not found"
    }

    $ret= @()
    $h = $hubber

    while($h.level -ge 0){
        $ret += $h
        $h = $h.manager
    }

    # Convert to PSCustomObject
    $ret = $ret | ForEach-Object{ [pscustomobject]$_}

    return $ret

} Export-ModuleMember -Function Get-HubberPath