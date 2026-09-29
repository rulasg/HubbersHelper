function Test_ConvertYamlToJson_ConvertsNestedYaml {
    [CmdletBinding()]
    param()

    # Arrange
    $tempDirectory = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "HubbersHelper-$([guid]::NewGuid())"
    $inputPath = Join-Path -Path $tempDirectory -ChildPath 'hubbers.yml'
    $outputPath = Join-Path -Path $tempDirectory -ChildPath 'hubbers.json'
    $null = New-Item -Path $tempDirectory -ItemType Directory

    @'
hubbers:
  - github_login: octocat
    active: true
'@ | Set-Content -LiteralPath $inputPath -Encoding utf8

    try {
        # Act
        Convert-YamlToJson -InputPath $inputPath -OutputPath $outputPath
        $result = Get-Content -LiteralPath $outputPath -Raw | ConvertFrom-Json

        # Assert
        Assert-AreEqual -Expected 'octocat' -Presented $result.hubbers[0].github_login
        Assert-AreEqual -Expected $true -Presented $result.hubbers[0].active
    }
    finally {
        Remove-Item -LiteralPath $inputPath, $outputPath -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $tempDirectory -Force -ErrorAction SilentlyContinue
    }
}
