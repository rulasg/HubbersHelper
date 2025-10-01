function Test_searchHubber_Success_Name{

    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    $result = search-Hubber -Name "Mich"

    $resultNames = $result.name
    Assert-Count -Expected 2 -Presented $resultNames
    Assert-Contains -Expected "Michael Johnson" -Presented $resultNames
    Assert-Contains -Expected "Michelle Brown" -Presented $resultNames

}

function Test_searchHubber_Success_Handle{
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    $result = search-Hubber -Handle "2"

    $resultHandles = $result.github_login
    Assert-Count -Expected 2 -Presented $resultHandles
    Assert-Contains -Expected "user2" -Presented $resultHandles
    Assert-Contains -Expected "user12" -Presented $resultHandles

}

function Test_searchHubber_Success_Name_Handle{
    Reset-InvokeCommandMock
    Mock_Database
    $filePath = Get-MockFileFullPath -fileName "hubbers.json"
    $result = Import-HubbersList -Path $filePath

    $result = search-Hubber -Handle "2" -Name "Davis"

    Assert-AreEqual -Expected "user2" -Presented $result.github_login
    Assert-AreEqual -Expected "Jennifer Davis" -Presented $result.name
}



function Test_searchHubber_Fail_NoParams{
    Reset-InvokeCommandMock
    Mock_Database

    Start-MyTranscript
    $result = search-Hubber @ErrorParameters
    $transcriptContent = Stop-MyTranscript

    Assert-Contains -Expected "Error: Please specify either Name or Handle, or both." -Presented $transcriptContent

}