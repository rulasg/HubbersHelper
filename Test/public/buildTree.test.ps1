function Test_Load_HubbersList{

    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbers.json"

    $result = Import-HubbersList -Path $filePath
 
    Assert-AreEqual -Expected user0 -Presented $result.HubbersList.user12.manager.manager.github_login

    # total employeed
    Assert-AreEqual -Expected 13 -Presented $result.totalHubbers
    Assert-AreEqual -Expected 13 -Presented $result.HubbersList.count
}

function Test_GetHubbersList{
    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbers.json"

    $result = Import-HubbersList -Path $filePath

    $result = Get-HubbersList

    Assert-AreEqual -Expected user0 -Presented $result.user12.manager.manager.github_login
}

function Test_GetHubbersTree{
    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbers.json"

    $result = Import-HubbersList -Path $filePath

    $result = Get-HubbersTree

    Assert-AreEqual -Expected user0 -Presented $result.github_login
    Assert-AreEqual -Expected user12 -Presented $result.reports.user3.reports.user12.github_login
}

