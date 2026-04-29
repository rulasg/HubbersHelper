function Test_ShowHubberOrg_DisplaysOrgTreeFromHandle {

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $null = Import-HubbersList -Path $filePath
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
    $null = Import-HubbersList -Path $filePath
    $testHandle = "nonexistent"

    # Act
    Show-HubberOrg -Handle $testHandle @ErrorParameters

    # Assert
    Assert-AreEqual -Expected "Hubber with handle 'nonexistent' not found" -Presented $errorVar.Exception.Message
}
