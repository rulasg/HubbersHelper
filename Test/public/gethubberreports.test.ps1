
function Test_GetHubberReports_Success_All{

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersListV2 -Path $filePath

    $l = Get-HubbersList

    foreach($h in $l.Keys){

        # Act
        $r = Get-HubberReports -Handle $h

        # Assert
        Assert-Count -Expected ($l.$h.totalReports) -Presented $r
    }
}

function Test_GetHubberReports_HubberNotFound{

    # Arrange
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    # Act & Assert
    Assert-NotImplemented
}
