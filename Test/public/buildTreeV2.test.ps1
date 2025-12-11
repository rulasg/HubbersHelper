function Test_ImportHubbersListV2{

    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbersV2.json"

    $result = Import-HubbersListV2 -Path $filePath
 
    Assert-AreEqual -Expected user0 -Presented $result.HubbersList.user12.manager.manager.github_login

    # total employeed
    Assert-AreEqual -Expected 15 -Presented $result.totalHubbers
    Assert-AreEqual -Expected 15 -Presented $result.HubbersList.count

    # tree structure
    Assert-AreEqual -Expected 2 -Presented $result.HubbersTree.Count
    Assert-Contains -Expected "user0" -Presented $result.HubbersTree.Keys
    Assert-Contains -Expected "user13" -Presented $result.HubbersTree.Keys
}

function Test_GetHubbersListV2{
    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbers.json"

    $result = Import-HubbersListV2 -Path $filePath

    $result = Get-HubbersList

    Assert-AreEqual -Expected user0 -Presented $result.user12.manager.manager.github_login
}

function Test_GetHubbersTreeV2{
    Reset-InvokeCommandMock
    Mock_Database

    $filePath = Get-MockFileFullPath -fileName "hubbers.json"

    $result = Import-HubbersListV2 -Path $filePath

    $result = Get-HubbersTree

    Assert-Count -Expected 1 -Presented $result.Count
    Assert-AreEqual -Expected "user0" -Presented $result.Keys[0]
    Assert-AreEqual -Expected user0 -Presented $result.user0.github_login
    Assert-AreEqual -Expected user12 -Presented $result.user0.reports.user3.reports.user12.github_login
}

