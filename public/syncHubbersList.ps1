Set-MyInvokeCommandAlias -alias GetRepoFile -Command 'RepoHelper\Get-RepoFile -Owner {owner} -Repo {repo} -Path "{path}"'
Set-MyInvokeCommandAlias -alias GetJsonFilePath -Command 'echo ~/hubbers.json'
Set-MyInvokeCommandAlias -alias GetYamlFilePath -Command 'echo ~/hubbers.yml'

function Sync-HubbersTheHubOrgDataSource{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$YamlOutputFile
    )

    $path = "docs/_data/hubbers.yml"
    $owner = "github"
    $repo = "thehub"

    # $content = RepoHelper\Get-RepoFile -Owner $owner -Repo $repo -Path $path
    $content = Invoke-MyCommand -Command GetRepoFile -Parameters @{ owner = $owner; repo = $repo; path = $path }
    
    Set-Content -Path $YamlOutputFile -Value $content

    "Updated $YamlOutputFile with content from $owner/$repo - $path" | Write-MyHost

} Export-ModuleMember -Function Sync-HubbersTheHubOrgDataSource

function Sync-HubbersList{
    [CmdletBinding()]
    param()

    # Get File Path.
    # Decouple for testing
    $yamlfile = Invoke-MyCommand -Command GetYamlFilePath
    $jsonFile = Invoke-MyCommand -Command GetJsonFilePath

    "Syncing Hubbers list..." | Write-MyHost -ForegroundColor DarkMagenta
    Sync-HubbersTheHubOrgDataSource -YamlOutputFile $yamlfile
    Write-MyHost 
    
    "Converting Hubbers YAML to JSON..." | Write-MyHost -ForegroundColor DarkMagenta
    Convert-YamlToJson -InputPath $yamlfile -OutputPath $jsonFile
    "Converted $yamlfile to $jsonFile" | Write-MyHost 
    Write-MyHost 

    "Importing Hubbers list..." | Write-MyHost -ForegroundColor DarkMagenta
    Import-HubbersList -Path $jsonFile
    Write-MyHost 

} Export-ModuleMember -Function Sync-HubbersList
