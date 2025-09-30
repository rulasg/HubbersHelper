function Save-HubbersListDb {
    param(
        [Parameter(Mandatory)][object]$Hubbers
    )

    Save-DatabaseKey -Key HubbersList -Value $Hubbers -DBFormat XML

}

function Save-HubbersTreeDb {
    param(
        [Parameter(Mandatory)][object]$Hubbers
    )

    Save-DatabaseKey -Key HubbersTree -Value $Hubbers -DBFormat XML

} 

function Get-HubbersList {
    param()

    $hubbers = Get-DatabaseKey -Key HubbersList -DBFormat XML

    return $hubbers
} Export-ModuleMember -Function Get-HubbersList

function Get-HubbersTree {
    param()

    $tree = Get-DatabaseKey -Key HubbersTree -DBFormat XML

    return $tree
} Export-ModuleMember -Function Get-HubbersTree