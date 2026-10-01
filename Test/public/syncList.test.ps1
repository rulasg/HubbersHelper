
function Test_SyncHubbersList{

    Reset-InvokeCommandMock
    Mock_Database

    $cmd = 'RepoHelper\Get-RepoFile -Owner github -Repo thehub -Path "docs/_data/hubbers.yml"'

    MockCall -Command $cmd -fileName hubbersV2.yml
    MockCallToString -Command 'echo ~/hubbers.yml' -OutString "./hubbers.yml"
    MockCallToString -Command 'echo ~/hubbers.json' -OutString "./hubbers.json"
    
    #Act
    $result = Sync-HubbersList 
 
    Assert-AreEqual -Expected user0 -Presented $result.HubbersList.user12.manager.manager.github_login

    # total employeed
    Assert-AreEqual -Expected 15 -Presented $result.totalHubbers
    Assert-AreEqual -Expected 15 -Presented $result.HubbersList.count

    # tree structure
    Assert-Count -Expected 2 -Presented $result.HubbersTree
    Assert-Contains -Expected "user0" -Presented $result.HubbersTree.Keys
    Assert-Contains -Expected "user13" -Presented $result.HubbersTree.Keys
}

function Test_SyncHubbersList_GetHubbersList{
    Reset-InvokeCommandMock
    Mock_Database

    $cmd = 'RepoHelper\Get-RepoFile -Owner github -Repo thehub -Path "docs/_data/hubbers.yml"'

    MockCall -Command $cmd -fileName hubbersV2.yml
    MockCallToString -Command 'echo ~/hubbers.yml' -OutString "./hubbers.yml"
    MockCallToString -Command 'echo ~/hubbers.json' -OutString "./hubbers.json"
    
    #Act
    $result = Sync-HubbersList

    $result = Get-HubbersList

    Assert-AreEqual -Expected user0 -Presented $result.user12.manager.manager.github_login
}

function Test_SyncHubbersList_GetHubbersTreeV2{
    Reset-InvokeCommandMock
    Mock_Database

    $cmd = 'RepoHelper\Get-RepoFile -Owner github -Repo thehub -Path "docs/_data/hubbers.yml"'

    MockCall -Command $cmd -fileName hubbersV2.yml
    MockCallToString -Command 'echo ~/hubbers.yml' -OutString "./hubbers.yml"
    MockCallToString -Command 'echo ~/hubbers.json' -OutString "./hubbers.json"
    
    #Act
    $result = Sync-HubbersList

    $result = Get-HubbersTreeRoot

    # tree structure
    Assert-Count -Expected 2 -Presented $result
    Assert-Contains -Expected "user0" -Presented $result.Keys
    Assert-Contains -Expected "user13" -Presented $result.Keys
    Assert-AreEqual -Expected user0 -Presented $result.user0.github_login
    Assert-AreEqual -Expected user12 -Presented $result.user0.reports.user3.reports.user12.github_login
}

