function Test_Build_HubbersTree{

    Reset-InvokeCommandMock
    Mock_Database

    MockCallJson -Command "Invoke-GetHubbers" -Filename "hubbers.json" -AsHashtable

    $result = Build-HubbersTree

    Assert-AreEqual -Expected user0 -Presented $result.HubbersList.user12.manager.manager.github_login

    # total employeed
    Assert-AreEqual -Expected 13 -Presented $result.totalHubbers
    Assert-AreEqual -Expected 13 -Presented $result.HubbersList.count

}

