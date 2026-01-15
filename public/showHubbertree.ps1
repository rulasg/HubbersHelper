function Show-HubberTree{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Handle
    )

    $path = Get-HubberPath -Handle $Handle
    [array]::Reverse($path)
    
    for($i = 0; $i -lt $path.Count; $i++){
        $hubber = $path[$i]
        $indent = "  " * $i
        
        if($i -eq 0){
            # First node (top of tree)
            WriteHost "$indent- " $hubber
        } else {
            # Other nodes
            WriteHost "$indent└─ " $hubber
        }
    }
} Export-ModuleMember -Function Show-HubberTree

function WriteHost{
    param(
        [Parameter(Position=0)][string]$prefix,
        [Parameter(Position=1)][object]$user
    )

    Write-Host $prefix -NoNewline -ForegroundColor green

    Write-Host "$($user.name)"         -NoNewline -ForegroundColor white
    Write-Host " | "                   -NoNewline
    Write-Host "$($user.title)"        -NoNewline -ForegroundColor cyan
    Write-Host " | "                   -NoNewline
    Write-Host "$($user.totalReports)" -NoNewline -ForegroundColor DarkRed
    Write-Host " | "                   -NoNewline
    Write-Host "$($user.github_login)" -NoNewline -ForegroundColor yellow

    Write-Host ""
    
}