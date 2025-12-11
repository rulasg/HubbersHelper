function Test_GetHubberPath_Success{

    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    $result = Get-HubberPath -Handle "user4"

    Assert-Count -Expected 3 -Presented $result

    Assert-AreEqual -Expected "user4" -Presented $result[0].github_login
    Assert-AreEqual -Expected "user2" -Presented $result[1].github_login
    Assert-AreEqual -Expected "user0" -Presented $result[2].github_login
}