function Test_ShowHubbersConnect_DisplaysConnectionTree {

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbersV2.json"
    $null = Import-HubbersListV2 -Path $filePath

    # Act
    Show-HubberConnect -FromHandle "rulasg" -ToHandle "evgenijrenke"

    # Assert
    Assert-AreEqual -Expected $true -Presented $?
}

function Test_ShowHubbersConnect_WhenHubberMissing {

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbersV2.json"
    $null = Import-HubbersListV2 -Path $filePath

    # Act
    Show-HubberConnect -FromHandle "missing-hubber" -ToHandle "rulasg" @ErrorParameters

    # Assert
    Assert-AreEqual -Expected "Hubber with handle 'missing-hubber' not found" -Presented $errorVar.Exception.Message
}
