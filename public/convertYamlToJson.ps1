function Convert-YamlToJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$InputPath,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Depth = 100
    )

    $resolvedInputPath = (Resolve-Path -LiteralPath $InputPath -ErrorAction Stop).ProviderPath
    $yaml = Get-Content -LiteralPath $resolvedInputPath -Raw -ErrorAction Stop
    $data = ConvertFrom-Yaml -Yaml $yaml -ErrorAction Stop
    $json = $data | ConvertTo-Json -Depth $Depth -ErrorAction Stop

    Set-Content -LiteralPath $OutputPath -Value $json -Encoding utf8 -ErrorAction Stop
} Export-ModuleMember -Function Convert-YamlToJson
