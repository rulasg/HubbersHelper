function Open-HubbersTheHubOrgDataSource{
    [CmdletBinding()]
    [alias("Open-HubbersDataSource")]
    param()

    $url = "https://thehub.github.com/assets/org-data.json"
    
    Open-Url -Url $url
} Export-ModuleMember -Function Open-HubbersTheHubOrgDataSource

function Open-HubbersTheHubOrg{
    $url = "https://thehub.github.com/org"
    
    Open-Url -Url $url
} Export-ModuleMember -Function Open-HubbersTheHubOrg

function Open-HubbersLocalDataSource{
    $file = "~/hubbers.json"

    Open-File -Path $file
} Export-ModuleMember -Function Open-HubbersLocalDataSource

function Sync-HubbersTheHubOrgDataSource{
    $path = "docs/_data/hubbers.yml"
    $output = "~/hubbers.yml"
    $owner = "github"
    $repo = "thehub"

    $content = RepoHelper\Get-RepoFile -Owner $owner -Repo $repo -Path $path
    Set-Content -Path $output -Value $content

    "Updated $output with content from $owner/$repo - $path" | Write-MyHost

} Export-ModuleMember -Function Sync-HubbersTheHubOrgDataSource