$script:Get_Argument_Handles = {
     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    "Get-Argument_Handles:" | Write-Mydebug -Section "ArgumentCompleter" -Object $PSBoundParameters

    # Cache to memory
    if(-not $script:handleslist){
        "Caching hubbers list for completion" | Write-Mydebug -Section "ArgumentCompleter"
        # ipmol HubbersHelper
        try { "Caching hubbers list for completion" | Write-Mydebug -Section "ArgumentCompleter"; $r = Get-HubbersList }
        catch { "Error getting hubbers list for completion: $($_.Exception.Message)" | Write-Warning ; return}
        $script:handleslist = $r.keys
    }

    "Found $($script:handleslist.Count) hubbers for completion" | Write-Mydebug -Section "ArgumentCompleter"

    if($wordToComplete.length -ge 1){
        "Filtering hubbers list for completion with word '$wordToComplete'" | Write-Mydebug -Section "ArgumentCompleter"
        $ret = $script:handleslist | ConvertTo-CompleteResults -wordToComplete $wordToComplete -startwith
        return $ret
    } else{
        "No filtering applied for completion, returning all hubbers" | Write-Mydebug -Section "ArgumentCompleter"
        return @()
    }
}