
Register-ArgumentCompleter -CommandName Get-Hubber -ParameterName Handle -ScriptBlock $Get_Argument_Handles

function Get-Hubber{
    [CmdletBinding()]
    [alias("gbb")]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][string]$Handle,
        [Parameter()][switch]$AsHashtable
    )

    process{

        $hubbers = Get-HubbersList
        
        $ret = $hubbers.$Handle
        
        return [PSCustomObject] $ret
    }

} Export-ModuleMember -Function Get-Hubber -alias gbb
