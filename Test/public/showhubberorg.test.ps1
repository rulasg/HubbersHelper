function Test_ShowHubberOrg_DisplaysOrgTreeFromHandle {

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath
    $testHandle = "user1"

    # Act
    Show-HubberOrg -Handle $testHandle

    # Assert
    Assert-AreEqual -Expected $true -Presented $?
}

function Test_ShowHubberOrg_HandlerNotFound {

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath
    $testHandle = "nonexistent"

    # Act
    Show-HubberOrg -Handle $testHandle -ErrorAction SilentlyContinue

    # Assert
    Assert-AreEqual -Expected $false -Presented $?
}
