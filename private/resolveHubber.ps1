function Resolve-Hubber{
    param(
        [Parameter(Mandatory)][string]$Handle,
        [Parameter()][switch]$Manager
    )

    $hubber = Get-Hubber -Handle $Handle
    
    if ($null -eq $hubber) {
        throw "Hubber with handle '$Handle' not found"
    }

    if($Manager) {
        $hubber = $hubber.manager

        if($null -eq $hubber) {
            throw "Hubber does not have a manager."
        }
    }

    return $hubber
}