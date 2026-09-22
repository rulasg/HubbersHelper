
Register-ArgumentCompleter -CommandName Show-HubberTree -ParameterName Handle -ScriptBlock $Get_Argument_Handles

function Show-HubberTree{
    [CmdletBinding()]
    [Alias("shbbt")]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][alias("github_login")][string]$Handle
    )

    process{

        $path = Get-HubberTree -Handle $Handle
        [array]::Reverse($path)
        
        $maxReportsCountLength = ($path.reportsCount | Measure-Object -Property Length -Maximum).Maximum
        $maxTitleLength = ($path.title | Measure-Object -Property Length -Maximum).Maximum
        
        $maxNameLength = ($path.name | Measure-Object -Property Length -Maximum).Maximum
        $maxNameLength = $path.count * 2 + $maxNameLength
        
        for($i = 0; $i -lt $path.Count; $i++){
            $hubber = $path[$i]
            $indent = "  " * $i
            
            $prefix = if($i -eq 0) { "- " } else { "└─" }
            
            WriteUser "$indent$prefix" $hubber -NameFullLength ($maxNameLength - $i*2) -TitleFullLength $maxTitleLength -ReportsFullLength $maxReportsCountLength
        }
    }
} Export-ModuleMember -Function Show-HubberTree -Alias shbbt

function WriteUser{
    param(
        [Parameter(Position=0)][string]$prefix,
        [Parameter(Position=1)][object]$user,
        [Parameter()][switch]$NoNewLine,
        [Parameter()][int]$NameFullLength = 0,
        [Parameter()][int]$TitleFullLength = 0,
        [Parameter()][int]$ReportsFullLength = 0
    )

    Write-Host $prefix -NoNewline -ForegroundColor green
    Write-Host (getStringWithPad $user.name $NameFullLength)    -NoNewline -ForegroundColor white
    Write-Host " | "                                            -NoNewline
    Write-Host (getStringWithPad $user.title $TitleFullLength)  -NoNewline -ForegroundColor cyan
    Write-Host " | "                                            -NoNewline
    Write-Host (getStringWithPad $user.reportsCount $ReportsFullLength)   -NoNewline -ForegroundColor DarkRed
    Write-Host " | "                                            -NoNewline
    Write-Host (getStringWithPad $user.github_login)  -NoNewline -ForegroundColor yellow

    if(-not $NoNewLine){
        Write-Host ""
    }
}

function getReportsCount($user){
    $($user.reports.count)/$($user.totalReports)
}
    

function getStringWithPad{
    param(
        [string]$txt,
        [int]$totalLength
    )

    $x = $txt.length
    $y = $($totalLength -eq 0) ? $x : $totalLength
    $p = $y - $x

    $ret = $txt + " " * $p
    
    return $ret 
}