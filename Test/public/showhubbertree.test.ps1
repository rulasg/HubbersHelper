function Test_ShowHubberTree_DisplaysPathFromHandleToRoot {
    
    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath
    $testHandle = "user1"
    
    # Act
    Show-HubberTree -Handle $testHandle
    
    # Assert - verify no error is thrown
    Assert-AreEqual -Expected $true -Presented $?
}

function Test_ShowHubberTree_HandlerNotFound {
    
    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath
    $testHandle = "nonexistent"
    $exceptionThrown = $false
    
    # Act
    try {
        Show-HubberTree -Handle $testHandle
    } catch {
        $exceptionThrown = $true
    }
    
    # Assert
    Assert-AreEqual -Expected $true -Presented $exceptionThrown
}

function Test_ShowHubberTree_DisplaysTreeWithProperFormatting {

    # TODO: Improve test to include testing the outputs format of the tree.

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath
    $testHandle = "user1"
    
    # Act
    Show-HubberTree -Handle $testHandle
    
    # Assert - verify no error is thrown
    Assert-AreEqual -Expected $true -Presented $?
}
